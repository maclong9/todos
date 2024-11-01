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
    
    /// Wrap html in page structure
    func wrapInLayout() -> String {
        """
        <!doctype html>
        <html lang="en">
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <title>\(self.title) | Swift Todos</title>
                <meta name="description" content="\(self.description)">
                <meta property="og:image" content="og.png">
                <meta name="apple-itunes-app" content="app-id=APP_ID,affiliate-data=AFFILIATE_ID,app-argument=SOME_TEXT">
                <link rel="stylesheet" href="styles.css">
                <link rel="icon" href="icon.svg">
            </head>
            <body>
                <header>
                    <a id="logo" href="/">Swift Todos</a>
                    <nav>
                        <a class="btn primary" href="/dashboard">Get Started</a>
                    </nav>
                </header>
                <main>
                    \(self.content)
                </main>
                <footer>
                    <small>
                        © \(Calendar.current.component(.year, from: Date())) -
                        <a href="https://github.com/maclong9">Mac Long</a>
                    </small>
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
