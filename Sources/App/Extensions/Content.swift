import Hummingbird

/// Type wrapping HTML code. Will convert to HBResponse that includes the correct content-type header
struct HTML: ResponseGenerator {
  let title: String
  let description: String
  let isLoggedIn: Bool?
  let content: String

  init(
    title: String,
    description: String =
      "Take control of your life with this wonderful todo list application.",
    isLoggedIn: Bool? = false,
    content: String
  ) {
    self.title = title
    self.description = description
    self.isLoggedIn = isLoggedIn
    self.content = content
  }

  public func response(from request: Request, context: some RequestContext) throws -> Response {
    .init(
      status: .ok,
      headers: [.contentType: "text/html"],
      body: .init(
        byteBuffer: ByteBuffer(
          string: LayoutView(
            title: title,
            description: description,
            isLoggedIn: isLoggedIn ?? false,
            content: content
          )
          .render()
        )
      )
    )
  }
}
