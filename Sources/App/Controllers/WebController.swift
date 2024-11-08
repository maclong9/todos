import FluentKit
import Hummingbird
import HummingbirdAuth
import HummingbirdFluent

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
            return .redirect(to: "\(self.to)", type: .found)
        }
    }
}

/// Serves HTML pages
struct WebController {
    typealias Context = AppRequestContext
    let fluent: Fluent
    let sessionAuthenticator: SessionAuthenticator<Context, UserRepository>
    
    init(fluent: Fluent, sessionAuthenticator: SessionAuthenticator<Context, UserRepository>) {
        self.fluent = fluent
        self.sessionAuthenticator = sessionAuthenticator
    }
    
    /// Add routes for webpages
    func addRoutes(to router: Router<Context>) {
        // Unauthenticated routes
        router.group()
            .get("/log-in", use: self.login)
            .post("/log-in", use: self.loginDetails)
            .get("/sign-up", use: self.signup)
            .post("/sign-up", use: self.signupDetails)
            .get("/reset-password", use: self.reset)
            .post("/reset-password", use: self.resetDetails)
            .get("/", use: self.home)
        
        // Authenticated routes
        router.group()
            .add(middleware: self.sessionAuthenticator)
            .add(middleware: RedirectMiddleware(to: "/login"))
            .get("/dashboard", use: self.dashboard)
    }
    
    struct Todo {
        let title: String
        let completed: Bool
    }
    
    /// Home page for marketing content
    @Sendable func home(request: Request, context: Context) async throws -> HTML {
       return HTML(
            title: "Home",
            isLoggedIn: true,
            content: HomeView().render()
        )
    }
    
    struct SignupDetails: Decodable {
        let name: String
        let email: String
        let password: String
        let confirmPassword: String
    }
    
    /// Signup page
    @Sendable func signup(request: Request, context: Context) async throws -> HTML {
        HTML(title: "Sign Up", content: AuthView(action: .signup).render())
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
            
            let user = try await User.create(
                name: details.name,
                email: details.email,
                password: details.password,
                db: self.fluent.db()
            )
            
            try context.sessions.setSession(user.requireID())
            return .redirect(to: "/dashboard", type: .found)
        } catch let error as HTTPError {
            if error.status == .badRequest || error.status == .conflict {
                var response = try HTML(
                    title: "Sign Up",
                    description: "Take control of your life with this wonderful todo list application.",
                    content: AuthView(action: .signup, errorMessage: String(error.description.split(separator: ",")[1])).render()
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
        print("Login attempt for:", details.email)
        
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
            } else {
                let errorHTML = HTML(
                    title: "Log In",
                    content: AuthView(action: .login, errorMessage: "Invalid credentials").render()
                )
                var response = try errorHTML.response(from: request, context: context)
                response.status = .badRequest
                return response
            }
        } catch let error as FluentError {
            let errorHTML = HTML(
                title: "Log In",
                content: AuthView(action: .login, errorMessage: error.localizedDescription).render()
            )
            var response = try errorHTML.response(from: request, context: context)
            response.status = .internalServerError
            return response
        } catch {
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
    
    struct ResetDetails: Decodable {
        let email: String
    }
    /// Reset password POST page
    @Sendable func resetDetails(request: Request, context: Context) async throws -> Response {
        let details = try await request.decode(as: ResetDetails.self, context: context)
        print("reset password for:", details.email)
        return .redirect(to: "/")
    }
    
    /// Renders the dashboard page that provides CRUD operations for managing todos
    @Sendable func dashboard(request: Request, context: Context) async throws -> HTML {
        // get user and list of todos attached to user from database
        let user = try context.requireIdentity()
        let todos = try await user.$todos.get(on: self.fluent.db())
        
        return HTML(
            title: "Dashboard",
            isLoggedIn: user.name.isEmpty == false,
            content: DashboardView(user: user, todos: todos).render()
        )
    }
}
