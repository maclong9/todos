import FluentKit
import Hummingbird
import HummingbirdAuth
import HummingbirdFluent

// TODO: Add Reset Password and Email Confirmation Flows

/// A middleware that redirects unauthenticated users to the login page
///
/// This middleware ensures that protected routes are only accessible to
/// authenticated users. When an unauthenticated user attempts to access
/// a protected route, they are automatically redirected to the login page.
///
/// ## Topics
/// ### Configuration
/// - ``init(to:)``
/// - ``handle(_:context:next:)``
struct RedirectMiddleware<Context: AuthRequestContext>: RouterMiddleware {
    // path to redirect unauthenticated users to
    let to: String

    /// Handles the incoming request
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request
    ///   - context: The authentication context
    ///   - next: The next middleware in the chain
    /// - Returns: Either the next middleware's response or a redirect response
    /// - Throws: Any error from the middleware chain
    func handle(
        _ request: Request,
        context: Context,
        next: (Request, Context) async throws -> Output
    ) async throws -> Response {
        if context.identity != nil {
            return try await next(request, context)
        }
        else {
            return .redirect(to: "\(self.to)", type: .found)
        }
    }
}

/// A controller that manages the web interface and HTML views
///
/// The `ViewController` handles rendering and serving HTML pages for the application,
/// including authentication flows and the main dashboard interface. It manages both
/// authenticated and unauthenticated routes.
///
/// ## Overview
/// The controller provides views for:
/// - Home page
/// - User authentication (login/signup)
/// - Password reset
/// - User dashboard
///
/// ## Topics
/// ### View Rendering
/// - ``home(request:context:)``
/// - ``dashboard(request:context:)``
///
/// ### Authentication Views
/// - ``login(request:context:)``
/// - ``signup(request:context:)``
/// - ``reset(request:context:)``
///
/// ### Form Processing
/// - ``loginDetails(request:context:)``
/// - ``signupDetails(request:context:)``
/// - ``resetDetails(request:context:)``
struct ViewController {
    typealias Context = AppRequestContext
    let fluent: Fluent
    let sessionAuthenticator: SessionAuthenticator<Context, UserRepository>

    init(fluent: Fluent, sessionAuthenticator: SessionAuthenticator<Context, UserRepository>) {
        self.fluent = fluent
        self.sessionAuthenticator = sessionAuthenticator
    }

    /// Add routes for web views
    func addRoutes(to router: Router<Context>) {
        // Unauthenticated routes
        router.group()
            .get("/", use: self.home)
            .get("/log-in", use: self.login)
            .post("/log-in", use: self.loginDetails)
            .get("/sign-up", use: self.signup)
            .post("/sign-up", use: self.signupDetails)
            .get("/reset-password", use: self.reset)
            .post("/reset-password", use: self.resetDetails)

        // Authenticated routes
        router.group()
            .add(middleware: self.sessionAuthenticator)
            .add(middleware: RedirectMiddleware(to: "/log-in"))
            .get("/dashboard", use: self.dashboard)
    }

    /// Renders the home page
    ///
    /// This page displays marketing content and varies based on whether
    /// the user is authenticated.
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request
    ///   - context: The application context
    /// - Returns: The rendered HTML page
    @Sendable func home(request: Request, context: Context) async throws -> HTML {
        HTML(
            title: "Home",
            isLoggedIn: request.cookies["SESSION_ID"] != nil,
            content: HomeView(
                isLoggedIn: request.cookies["SESSION_ID"] != nil
            ).render()
        )
    }

    /// Renders the user dashboard
    ///
    /// This page shows the user's todos and provides CRUD functionality.
    /// It requires authentication.
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request
    ///   - context: The application context
    /// - Returns: The rendered HTML page
    /// - Throws: An error if the user is not authenticated or if data fetching fails
    @Sendable func signup(request: Request, context: Context) async throws -> HTML {
        HTML(title: "Sign Up", content: AuthView(action: .signup).render())
    }

    struct SignupDetails: Decodable {
        let name: String
        let email: String
        let password: String
        let confirmPassword: String
    }

    /// Signup POST page
    @Sendable func signupDetails(request: Request, context: Context) async throws -> Response {
        let details = try await request.decode(as: SignupDetails.self, context: context)
        do {
            // Check passwords match first
            if details.password != details.confirmPassword {
                // Use badRequest for validation errors
                throw HTTPError(.badRequest, message: "Passwords do not match")
            }

            // create new user
            let user = try await User.create(
                name: details.name,
                email: details.email,
                password: details.password,
                db: self.fluent.db()
            )

            // log user in
            try context.sessions.setSession(user.requireID())

            // redirect to dashboard
            return .redirect(to: "/dashboard", type: .found)
        }
        catch let error as HTTPError {
            if error.status == .badRequest || error.status == .conflict {
                var response = try HTML(
                    title: "Sign Up",
                    description:
                        "Take control of your life with this wonderful todo list application.",
                    content: AuthView(
                        action: .signup,
                        errorMessage: String(error.description.split(separator: ",")[1])
                    ).render()
                ).response(from: request, context: context)
                response.status = error.status
                return response
            }
            throw error
        }
    }

    /// Login page
    @Sendable func login(request: Request, context: Context) async throws -> HTML {
        HTML(title: "Log In", content: AuthView(action: .login).render())
    }

    struct LoginDetails: Decodable {
        let email: String
        let password: String
    }

    /// Login POST page
    @Sendable func loginDetails(request: Request, context: Context) async throws -> Response {
        let details = try await request.decode(as: LoginDetails.self, context: context)

        do {
            // check if user exists in the database and then verify the entered password
            if let user = try await User.login(
                email: details.email,
                password: details.password,
                db: fluent.db()
            ) {
                // create session
                try context.sessions.setSession(user.requireID())
                // redirect to dashboard page
                return .redirect(to: "/dashboard", type: .found)
            }
            else {
                // render login page with `invalid credentials` message
                let errorHTML = HTML(
                    title: "Log In",
                    content: AuthView(action: .login, errorMessage: "Invalid credentials").render()
                )
                var response = try errorHTML.response(from: request, context: context)
                response.status = .badRequest
                return response
            }
        }
        catch {
            // render with api error
            let errorHTML = HTML(
                title: "Log In",
                content: AuthView(action: .login, errorMessage: error.localizedDescription).render()
            )
            var response = try errorHTML.response(from: request, context: context)
            response.status = .internalServerError
            return response
        }
    }

    /// Reset password page
    @Sendable func reset(request: Request, context: Context) async throws -> HTML {
        HTML(title: "Reset Password", content: AuthView(action: .resetPassword).render())
    }

    /// Reset password POST page
    struct ResetDetails: Decodable {
        let email: String
    }
    @Sendable func resetDetails(request: Request, context: Context) async throws -> Response {
        let details = try await request.decode(as: ResetDetails.self, context: context)
        print("reset password for:", details.email)
        return .redirect(to: "/")
    }

    /// Dashboard page with CRUD functionality
    @Sendable func dashboard(request: Request, context: Context) async throws -> HTML {
        // get user and list of todos attached to user from database
        let user = try context.requireIdentity()
        let todos = try await user.$todos.get(on: self.fluent.db())

        return HTML(
            title: "Dashboard",
            isLoggedIn: request.cookies["SESSION_ID"] != nil,
            content: DashboardView(user: user, todos: todos).render()
        )
    }
}
