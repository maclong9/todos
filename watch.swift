import Foundation
import Darwin

// ANSI color codes for terminal output
enum ConsoleColor: String {
  case reset = "\u{001B}[0m"
  case red = "\u{001B}[31m"
  case green = "\u{001B}[32m"
  case yellow = "\u{001B}[33m"
  case blue = "\u{001B}[34m"
  case cyan = "\u{001B}[36m"
}

// Helper to print colored messages
func printColored(_ message: String, color: ConsoleColor, bold: Bool = false) {
  let boldCode = bold ? "\u{001B}[1m" : ""
  print("\(color.rawValue)\(boldCode)\(message)\(ConsoleColor.reset.rawValue)")
}

// Paths to monitor
let paths = ["Sources"]
let fileManager = FileManager.default
let pollingInterval = 1.0  // Seconds between checks
let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
  return formatter
}()

// Server process management
var serverProcess: Process?

// Function to get all files in a directory recursively
func getFiles(in directory: String) -> [String] {
  guard let enumerator = fileManager.enumerator(atPath: directory) else {
    printColored("⚠️  Warning: Could not enumerate directory \(directory)", color: .yellow)
    return []
  }
  var files: [String] = []
  while let file = enumerator.nextObject() as? String {
    files.append((directory as NSString).appendingPathComponent(file))
  }
  return files
}

// Function to get the modification date of a file
func modificationDate(for file: String) -> Date? {
  do {
    let attributes = try fileManager.attributesOfItem(atPath: file)
    return attributes[.modificationDate] as? Date
  } catch {
    printColored("⚠️  Error accessing modification date for \(file): \(error)", color: .yellow)
    return nil
  }
}

// Stop the current Hummingbird server
func stopServer() {
  if let process = serverProcess, process.isRunning {
    printColored("🛑 Stopping Hummingbird server...", color: .yellow, bold: true)
    process.terminate()
    process.waitUntilExit()
    serverProcess = nil
    
    // Also kill any processes on port 8080 to be safe
    killProcessOnPort(8080)
  }
}

// Kill process running on specific port
func killProcessOnPort(_ port: Int) {
  let process = Process()
  process.executableURL = URL(fileURLWithPath: "/usr/bin/lsof")
  process.arguments = ["-ti", ":\(port)"]
  
  let pipe = Pipe()
  process.standardOutput = pipe
  
  do {
    try process.run()
    process.waitUntilExit()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if let pidString = output, !pidString.isEmpty {
      let pids = pidString.components(separatedBy: .newlines)
      for pidString in pids {
        if let pid = Int32(pidString.trimmingCharacters(in: .whitespacesAndNewlines)) {
          kill(pid, SIGTERM)
          printColored("🔪 Killed process \(pid) on port \(port)", color: .yellow)
        }
      }
    }
  } catch {
    // Ignore errors - process might not exist
  }
}

// Start the Hummingbird server
func startServer() {
  printColored("🚀 Starting Hummingbird server...", color: .cyan, bold: true)
  
  let process = Process()
  process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
  process.arguments = ["run"]
  process.currentDirectoryURL = URL(fileURLWithPath: "Sources")
  
  // Set up pipes for output
  let outputPipe = Pipe()
  let errorPipe = Pipe()
  process.standardOutput = outputPipe
  process.standardError = errorPipe
  
  do {
    try process.run()
    serverProcess = process
    
    // Read server output in background
    DispatchQueue.global().async {
      let outputHandle = outputPipe.fileHandleForReading
      outputHandle.readabilityHandler = { handle in
        let data = handle.availableData
        if !data.isEmpty {
          if let output = String(data: data, encoding: .utf8) {
            print(output, terminator: "")
          }
        }
      }
      
      let errorHandle = errorPipe.fileHandleForReading
      errorHandle.readabilityHandler = { handle in
        let data = handle.availableData
        if !data.isEmpty {
          if let output = String(data: data, encoding: .utf8) {
            print("\(ConsoleColor.red.rawValue)\(output)\(ConsoleColor.reset.rawValue)", terminator: "")
          }
        }
      }
    }
    
    printColored("✅ Hummingbird server started on port 8080", color: .green, bold: true)
    
  } catch {
    printColored("❌ Failed to start server: \(error)", color: .red, bold: true)
    serverProcess = nil
  }
}

// Restart the server (stop then start)
func restartServer() {
  stopServer()
  // Give it a moment to fully stop
  Thread.sleep(forTimeInterval: 0.5)
  startServer()
}

// Clear terminal (works on macOS/Linux)
func clearTerminal() {
  let process = Process()
  process.executableURL = URL(fileURLWithPath: "/usr/bin/clear")
  do {
    try process.run()
    process.waitUntilExit()
  } catch {
    printColored("⚠️  Failed to clear terminal: \(error)", color: .yellow)
  }
}

// Print header
func printHeader() {
  clearTerminal()
  printColored("🚀 Swift File Watcher for Hummingbird Server", color: .cyan, bold: true)
  printColored("Monitoring: Sources/**/*", color: .blue)
  printColored("Hummingbird Server: http://localhost:8080", color: .green)
  printColored("Polling interval: \(pollingInterval) seconds", color: .blue)
  printColored("Press Ctrl+C to stop", color: .blue)
  printColored("----------------------------------------", color: .blue)
}

// Handle Ctrl+C gracefully
signal(SIGINT) { _ in
  printColored("\n🛑 Shutting down...", color: .yellow, bold: true)
  stopServer()
  exit(0)
}

// Collect initial file list and their modification dates
var fileDates: [String: Date] = [:]
for path in paths {
  for file in getFiles(in: path) {
    if let date = modificationDate(for: file) {
      fileDates[file] = date
    }
  }
}

printHeader()

// Start initial server
startServer()
printColored("----------------------------------------", color: .blue)

// Main polling loop
while true {
  var changes: [(file: String, isNew: Bool)] = []

  // Check for changes or new files
  for path in paths {
    for file in getFiles(in: path) {
      if let newDate = modificationDate(for: file) {
        if let oldDate = fileDates[file] {
          if newDate > oldDate {
            changes.append((file: file, isNew: false))
            fileDates[file] = newDate
          }
        } else {
          changes.append((file: file, isNew: true))
          fileDates[file] = newDate
        }
      }
    }
  }

  // Handle deleted files
  fileDates.keys.forEach { file in
    if !fileManager.fileExists(atPath: file) {
      changes.append((file: file, isNew: false))
      fileDates.removeValue(forKey: file)
    }
  }

  // Process changes
  if !changes.isEmpty {
    printHeader()
    printColored(
      "📝 Detected Changes at \(dateFormatter.string(from: Date()))", color: .yellow, bold: true)
    for change in changes {
      let action = change.isNew ? "New file" : "Modified/Deleted"
      printColored("  • \(action): \(change.file)", color: .green)
    }
    printColored("----------------------------------------", color: .blue)
    restartServer()
    printColored("----------------------------------------", color: .blue)
    printColored("🔍 Resuming monitoring...", color: .blue)
  }

  // Sleep to avoid excessive CPU usage
  Thread.sleep(forTimeInterval: pollingInterval)
}
