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
        /// Unauthenticated routes
        router.group()
            .get("/login", use: self.login)
            .post("/login", use: self.loginDetails)
            .get("/signup", use: self.signup)
            .post("/signup", use: self.signupDetails)
            .get("/", use: self.home)
        
        /// Authenticated routes
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
        HTML(
            title: "Home",
            content: HomeView().render()
        )
    }
    
    /// Dashboard page listing todos and with add todo UI
    @Sendable func dashboard(request: Request, context: Context) async throws -> HTML {
        // get user and list of todos attached to user from database
        let user = try context.requireIdentity()
        let todos = try await user.$todos.get(on: self.fluent.db())
        let object: [String: Any] = [
            "name": user.name,
            "todos": todos,
        ]
        
        return HTML(
            title: "Dashboard",
            content: DashboardView(name: "placeholder").render()
        )
    }
    
    /// Login page
    @Sendable func login(request: Request, context: Context) async throws -> HTML {
        HTML(title: "Log In", content: AuthView(isLogin: true).render())
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
                    content: AuthView(isLogin: true, errorMessage: "Invalid credentials").render()
                )
                var response = try errorHTML.response(from: request, context: context)
                response.status = .badRequest
                return response
            }
        } catch let error as FluentError {
            let errorHTML = HTML(
                title: "Log In",
                content: AuthView(isLogin: true, errorMessage: error.localizedDescription).render()
            )
            var response = try errorHTML.response(from: request, context: context)
            response.status = .internalServerError
            return response
        } catch {
            let errorHTML = HTML(
                title: "Log In",
                content: AuthView(isLogin: true, errorMessage: error.localizedDescription).render()
            )
            var response = try errorHTML.response(from: request, context: context)
            response.status = .internalServerError
            return response
        }
    }
    
    struct SignupDetails: Decodable {
        let name: String
        let email: String
        let password: String
    }
    
    /// Signup page
    @Sendable func signup(request: Request, context: Context) async throws -> HTML {
        HTML(title: "Sign Up", content: AuthView().render())
    }
    
    /// Signup POST page
    @Sendable func signupDetails(request: Request, context: Context) async throws -> Response {
        let details = try await request.decode(as: SignupDetails.self, context: context)
        do {
            let user = try await User.create(
                name: details.name,
                email: details.email,
                password: details.password,
                db: self.fluent.db()
            )
            // After successful signup, create session and log user in
            try context.sessions.setSession(user.requireID())
            return .redirect(to: "/dashboard", type: .found)
        } catch let error as HTTPError {
            if error.status == .conflict {
                var response = try HTML(
                    title: "Sign Up",
                    description: "Take control o f your life with this wonderful todo list application.",
                    content: AuthView(errorMessage: "Email already in use.").render()
                ).response(from: request, context: context)
                response.status = .badRequest
                return response
            }
            throw error
        }
    }
}
