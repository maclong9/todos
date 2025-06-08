import Hummingbird

/// Type wrapping HTML code. Will convert to HBResponse that includes the correct
/// content-type header
struct HTMLResponse: ResponseGenerator {
  let html: String
  let redirect: String?
  let redirectType: Response.RedirectType?

  init(
    html: String, redirect: String? = nil,
    redirectType: Response.RedirectType? = nil
  ) {
    self.html = html
    self.redirect = redirect
    self.redirectType = redirectType
  }

  public func response(from request: Request, context: some RequestContext)
    throws -> Response
  {
    if let redirect = redirect {
      return .redirect(to: redirect, type: redirectType ?? .found)
    }
    let buffer = ByteBuffer(string: self.html)
    return .init(
      status: .ok, headers: [.contentType: "text/html"],
      body: .init(byteBuffer: buffer))
  }
}
