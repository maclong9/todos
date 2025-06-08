import FluentKit
import Hummingbird
import HummingbirdAuth
import HummingbirdFluent
import Logging

/// Redirects to login page if no user has been authenticated
struct RedirectMiddleware<Context: AuthRequestContext>: RouterMiddleware {
  let to: String
  func handle(
    _ request: Request,
    context: Context,
    next: (Request, Context) async throws -> Output
  ) async throws -> Response {
    if context.identity != nil {
      return try await next(request, context)
    } else {
      return .redirect(to: "\(self.to)?from=\(request.uri)", type: .found)
    }
  }
}

/// Serves HTML pages
struct WebController {
  typealias Context = AppRequestContext
  let fluent: Fluent
  let sessionAuthenticator: SessionAuthenticator<Context, UserRepository>
  let logger: Logger

  init(
    fluent: Fluent,
    sessionAuthenticator: SessionAuthenticator<Context, UserRepository>,
    logger: Logger
  ) {
    self.fluent = fluent
    self.sessionAuthenticator = sessionAuthenticator
    self.logger = logger
  }

  /// Add routes for web pages
  func addRoutes(to router: Router<Context>) {
    router.group()
      .get("/", use: self.home)
      .post("/api/auth/signup", use: self.signupDetails)
      .post("/api/auth/login", use: self.loginDetails)
      .post("/api/auth/reset-password", use: self.resetPassword)
      .add(middleware: self.sessionAuthenticator)
      .add(middleware: RedirectMiddleware(to: "/"))
      .get("/dashboard", use: self.dashboard)
  }

  /// Home page with authentication UI
  @Sendable func home(request: Request, context: Context) async throws
    -> HTMLResponse
  {
    if context.identity != nil {
      // If user is authenticated, redirect to dashboard
      return try await self.dashboard(request: request, context: context)
    }

    // Check for messages in query parameters
    let errorMessage = request.uri.queryParameters["error"]?.first.map(
      String.init)
    let successMessage = request.uri.queryParameters["success"]?.first.map(
      String.init)
    let email = request.uri.queryParameters["email"]?.first.map(String.init)

    return HTMLResponse(
      html: try HomeView(
        errorMessage: errorMessage,
        email: email,
        successMessage: successMessage
      ).render()
    )
  }

  /// Dashboard page for authenticated users
  @Sendable func dashboard(request: Request, context: Context) async throws
    -> HTMLResponse
  {
    let user = try context.requireIdentity()
    let todos = try await user.$todos.get(on: self.fluent.db())

    return HTMLResponse(
      html: try DashboardView(user: user, todos: todos).render())
  }

  struct LoginDetails: Decodable {
    let email: String
    let password: String
  }

  /// Login POST handler
  @Sendable func loginDetails(request: Request, context: Context) async throws
    -> Response
  {
    let details = try await request.decode(
      as: LoginDetails.self, context: context)

    if let user = try await User.login(
      email: details.email,
      password: details.password,
      db: fluent.db()
    ) {
      try context.sessions.setSession(user.requireID())
      // Return proper redirect instead of HTML
      return .redirect(to: "/dashboard", type: .found)
    } else {
      // Redirect back to home with error parameters
      let encodedEmail =
        details.email.addingPercentEncoding(
          withAllowedCharacters: .urlQueryAllowed) ?? ""
      let encodedError =
        "Invalid email or password".addingPercentEncoding(
          withAllowedCharacters: .urlQueryAllowed) ?? ""
      logger.error("\(encodedError)")
      return .redirect(
        to: "/?error=\(encodedError)&email=\(encodedEmail)",
        type: .found)
    }
  }

  struct SignupDetails: Decodable {
    let name: String
    let email: String
    let password: String
  }

  /// Signup POST handler
  @Sendable func signupDetails(request: Request, context: Context)
    async throws -> Response
  {
    let details = try await request.decode(
      as: SignupDetails.self, context: context)

    do {
      _ = try await User.create(
        name: details.name,
        email: details.email,
        password: details.password,
        db: self.fluent.db()
      )
      let encodedEmail =
        details.email.addingPercentEncoding(
          withAllowedCharacters: .urlQueryAllowed) ?? ""
      let encodedSuccess =
        "Account created successfully! Please log in."
        .addingPercentEncoding(
          withAllowedCharacters: .urlQueryAllowed) ?? ""
      logger.info("\(encodedSuccess)")
      return .redirect(
        to: "/?success=\(encodedSuccess)&email=\(encodedEmail)",
        type: .found)
    } catch let error as HTTPError {
      if error.status == .conflict {
        let encodedEmail =
          details.email.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedError =
          "An account with this email already exists."
          .addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed) ?? ""
        logger.error("\(encodedError)")
        return .redirect(
          to: "/?error=\(encodedError)&email=\(encodedEmail)",
          type: .found)
      } else {
        throw error
      }
    }
  }

  struct ResetPasswordDetails: Decodable {
    let email: String
  }

  /// Reset password POST handler
  @Sendable func resetPassword(request: Request, context: Context)
    async throws -> Response
  {
    _ = try await request.decode(
      as: ResetPasswordDetails.self, context: context)
    // TODO: Implement password reset logic
    return .redirect(to: "/", type: .found)
  }
}
