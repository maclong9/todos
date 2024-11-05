import Hummingbird

/// Type wrapping HTML code. Will convert to HBResponse that includes the correct
/// content-type header
struct HTML: ResponseGenerator {
    let title: String
    let description: String
    let content: String
    
    /// Initialize with default values
    init(
        title: String,
        description: String = "Take control of your life with this wonderful todo list application.",
        content: String
    ) {
        self.title = title
        self.description = description
        self.content = content
    }
    
    public func response(from request: Request, context: some RequestContext) throws -> Response {
        let buffer = ByteBuffer(
            string: LayoutView(title: title, description: description, content: content).render())
        return .init(status: .ok, headers: [.contentType: "text/html"], body: .init(byteBuffer: buffer))
    }
}
