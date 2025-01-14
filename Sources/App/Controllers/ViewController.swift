import FluentKit
import Hummingbird
import HummingbirdAuth
import HummingbirdFluent

/// A middleware that redirects unauthenticated users to the login page
///
/// This middleware ensures that protected routes are only accessible to
/// authenticated users. When an unauthenticated user attempts to access
/// a protected route, they are automatically redirected to the login page.
///
/// ## Security Considerations
/// This middleware should be added to any route that requires authentication.
struct RedirectMiddleware<Context: AuthRequestContext>: RouterMiddleware {
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
/// - Home page and marketing content
/// - User authentication (login/signup)
/// - Password reset functionality
/// - User dashboard with todo management
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
///
/// ### Request Types
/// - ``LoginDetails``
/// - ``SignupDetails``
/// - ``ResetDetails``
///
/// ### Related Types
/// - ``HTML``
/// - ``User``
/// - ``AuthView``
/// - ``DashboardView``
struct ViewController {
    typealias Context = AppRequestContext
    let fluent: Fluent
    let sessionAuthenticator: SessionAuthenticator<Context, UserRepository>

    init(fluent: Fluent, sessionAuthenticator: SessionAuthenticator<Context, UserRepository>) {
        self.fluent = fluent
        self.sessionAuthenticator = sessionAuthenticator
    }

    /// Adds all view routes to the application router
    ///
    /// - Parameter group: The router group to add routes to
    ///
    /// This method sets up both authenticated and unauthenticated routes:
    /// - Unauthenticated: Home, login, signup, password reset
    /// - Authenticated: Dashboard and auth routes
    ///
    /// ## Security Note
    /// The dashboard route is protected by both session authentication and
    /// the redirect middleware to ensure proper access control.
    func addRoutes(to router: Router<Context>) {
        // Unauthenticated routes
        router.group()
<<<<<<< HEAD
            .get("/", use: self.home)
            .get("/log-in", use: self.login)
            .post("/log-in", use: self.loginDetails)
            .get("/sign-up", use: self.signup)
            .post("/sign-up", use: self.signupDetails)
            .get("/reset-password", use: self.reset)
            .post("/reset-password", use: self.resetDetails)
=======
            .get("/", use: home)
            .get("/log-in", use: login)
            .post("/log-in", use: loginDetails)
            .get("/sign-up", use: signup)
            .post("/sign-up", use: signupDetails)
>>>>>>> parent of c5dd891 (chore: formatting)

        // Authenticated routes
        router.group()
            .add(middleware: self.sessionAuthenticator)
            .add(middleware: RedirectMiddleware(to: "/log-in"))
            .get("/dashboard", use: self.dashboard)
    }

    /// Renders the home page with dynamic content based on auth status
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request
    ///   - context: The application context
    /// - Returns: The rendered HTML page
    /// - Note: Content varies based on whether user is authenticated
    @Sendable func home(request: Request, context: Context) async throws -> HTML {
        HTML(
            title: "Home",
            isLoggedIn: request.cookies["SESSION_ID"] != nil,
            content: HomeView(
                isLoggedIn: request.cookies["SESSION_ID"] != nil
            ).render()
        )
    }

    /// Renders the signup page with the registration form
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request
    ///   - context: The application context
    /// - Returns: The rendered HTML signup form
    @Sendable func signup(request: Request, context: Context) async throws -> HTML {
        HTML(title: "Sign Up", content: AuthView(action: .signup).render())
    }

    /// Request structure for user signup
    struct SignupDetails: Decodable {
        let name: String
        let email: String
        let password: String
        let confirmPassword: String
    }

    /// Processes the signup form submission
    ///
    /// This method:
    /// 1. Validates the signup details
    /// 2. Creates a new user account
    /// 3. Establishes a session
    /// 4. Redirects to the dashboard
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request with form data
    ///   - context: The application context
    /// - Returns: A redirect response or error page
    /// - Throws: HTTP errors for validation failures or conflicts
    @Sendable func signupDetails(request: Request, context: Context) async throws -> Response {
        let details = try await request.decode(as: SignupDetails.self, context: context)
        do {
            // Check passwords match first
            if details.password != details.confirmPassword {
                throw HTTPError(.badRequest, message: "Passwords do not match")
            }

            // create new user
            let user = try await User.create(
                name: details.name,
                email: details.email,
                password: details.password,
                db: self.fluent.db()
            )

            // create session for new user
            try context.sessions.setSession(user.requireID())

            // redirect to dashboard
            return .redirect(to: "/dashboard", type: .found)
        }
        catch let error as HTTPError {
            if error.status == .badRequest || error.status == .conflict {
                var response = try HTML(
                    title: "Sign Up",
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

    /// Renders the login page with authentication form
    ///
    /// This route displays the login interface where users can enter their
    /// credentials to access their account. It provides a form for email
    /// and password input.
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request
    ///   - context: The application context
    /// - Returns: The rendered HTML login page
    /// - Note: This route is unauthenticated and accessible to all users
    @Sendable func login(request: Request, context: Context) async throws -> HTML {
        HTML(title: "Log In", content: AuthView(action: .login).render())
    }

    /// Request structure for user log-in
    struct LoginDetails: Decodable {
        let email: String
        let password: String
    }

    /// Processes user login attempts and manages authentication
    ///
    /// This route handles the login form submission and:
    /// 1. Validates the provided credentials
    /// 2. Creates a new session for authenticated users
    /// 3. Redirects successful logins to the dashboard
    /// 4. Handles authentication failures with appropriate error messages
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request containing login credentials
    ///   - context: The application context
    /// - Returns: A redirect response or error page
    /// - Throws: HTTP errors for invalid credentials or server errors
    /// - Note: Failed login attempts return a 400 status code with error details
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
            let errorHTML = HTML(
                title: "Log In",
                content: AuthView(action: .login, errorMessage: error.localizedDescription).render()
            )
            var response = try errorHTML.response(from: request, context: context)
            response.status = .internalServerError
            return response
        }
    }

    /// Renders the password reset request page
    ///
    /// This route displays a form where users can request a password reset
    /// by providing their email address. The actual reset flow should be
    /// implemented according to security best practices.
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request
    ///   - context: The application context
    /// - Returns: The rendered HTML password reset page
    /// - Note: This is currently a placeholder and needs full implementation
    @Sendable func reset(request: Request, context: Context) async throws -> HTML {
        HTML(title: "Reset Password", content: AuthView(action: .resetPassword).render())
    }

    /// Request structure for password reset
    struct ResetDetails: Decodable {
        let email: String
    }

    /// Processes password reset requests
    ///
    /// This route handles the password reset form submission. Currently a placeholder,
    /// it should be implemented to:
    /// 1. Validate the email address
    /// 2. Generate a secure reset token
    /// 3. Send a reset email to the user
    /// 4. Store the reset token securely
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request with the user's email
    ///   - context: The application context
    /// - Returns: A redirect response to the home page
    @Sendable func resetDetails(request: Request, context: Context) async throws -> Response {
        let details = try await request.decode(as: ResetDetails.self, context: context)
        print("reset password for:", details.email)
        return .redirect(to: "/")
    }

    /// Renders the user dashboard with todo management interface
    ///
    /// This authenticated route displays:
    /// 1. User's personal information
    /// 2. Their list of todos
    /// 3. Todo management controls
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request
    ///   - context: The application context containing user identity
    /// - Returns: The rendered HTML dashboard page
    /// - Throws: Authentication errors if user is not properly authenticated
    /// - Note: Protected by RedirectMiddleware and SessionAuthenticator
    @Sendable func dashboard(request: Request, context: Context) async throws -> HTML {
        // get user and list of todos attached to user from database
        let user = try context.requireIdentity()
        let todos = try await user.$todos.get(on: fluent.db())

        return HTML(
            title: "Dashboard",
            isLoggedIn: request.cookies["SESSION_ID"] != nil,
            content: DashboardView(user: user, todos: todos).render()
        )
    }
}
