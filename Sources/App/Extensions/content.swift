import Hummingbird
import Foundation

/// Type wrapping HTML code. Will convert to HBResponse that includes the correct
/// content-type header
struct HTML: ResponseGenerator {
    let title: String
    let description: String
    let content: String
    
    /// Initialize with default values
    init(
        title: String = "Home",
        description: String = "A simple web application",
        content: String
    ) {
        self.title = title
        self.description = description
        self.content = content
    }
    
    /// Wrap the html in default page structure with optional head content
    func wrapInLayout() -> String {
        """
        <!DOCTYPE html>
        <html lang="en">
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <title>\(self.title) | Todos</title>
                <meta name="description" content="\(self.description)">
            </head>
            <body>
                <header>
                    <a href="/">Logo</a>
                    <nav>
                        <a href="/dashboard">Get Started</a>
                    </nav>
                </header>
                <main>
                    \(self.content)
                </main>
                <footer>
                    <small>© \(Calendar.current.component(.year, from: Date())) - Mac Long</small>
                </footer>
            </body>
        </html>
        """
    }
    
    public func response(from request: Request, context: some RequestContext) throws -> Response {
        let fullHTML = wrapInLayout()
        let buffer = ByteBuffer(string: fullHTML)
        return .init(status: .ok, headers: [.contentType: "text/html"], body: .init(byteBuffer: buffer))
    }
}
