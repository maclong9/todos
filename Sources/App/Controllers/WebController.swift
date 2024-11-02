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
        return HTML(
            title: "Home",
            description: "Take control of your life with this wonderful todo list application.",
            content: """
                <section class="container">
                    <div class="left">
                        <h1>
                            Take Control of
                            <span class="gradient-highlight">Your Life</span>
                        </h1>
                        <p>
                           With this wonderful application, designed to make your life easier while staying out of the way. Take the first step in your new journey.
                        </p>
                        <div class="btn-group">
                            <a href="https://github.com/maclong9/todos" class="btn">View Source</a>
                            <a href="https://www.apple.com/uk/app-store/" class="btn primary">
                                Get the App
                            </a>
                        </div>
                    </div>
                    <img src="images/hero.png" />
                </section>
            """
        )
    }
    
    /// Dashboard page listing todos and with add todo UI
    @Sendable func dashboard(request: Request, context: Context) async throws -> HTML {
        // get user and list of todos attached to user from database
        let user = try context.requireIdentity()
        let todos = try await user.$todos.get(on: self.fluent.db())
        // Render todos template and return as HTML
        let object: [String: Any] = [
            "name": user.name,
            "todos": todos,
        ]
        print(object)
        
        return HTML(
            title: "Dashboard",
            description: "Take control of your life with this wonderful todo list application.",
            content: """
                <h1>Welcome Back, \(user.name)</h1>
            """
        )
    }
    
    /// Login page
    @Sendable func login(request: Request, context: Context) async throws -> HTML {
        return HTML(
            title: "Dashboard",
            description: "Take control of your life with this wonderful todo list application.",
            content: """
            <form class="auth-form" action="/login" method="post">
                <h1>Log In</h1>
                <div class="form-group">
                    <label for="email">Email</label>
                    <input 
                        type="email" 
                        id="email" 
                        name="email"
                        required
                    >
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input 
                        type="password" 
                        id="password" 
                        name="password"
                        required
                    >
                </div>
                <button class="primary" type="submit">Log In</button>
                <a href="/signup">No account yet?</a>
            </form>
            """
        )
    }
    
    struct LoginDetails: Decodable {
        let email: String
        let password: String
    }
    
    /// Login POST page
    @Sendable func loginDetails(request: Request, context: Context) async throws -> Response {
        let details = try await request.decode(as: LoginDetails.self, context: context)
        // check if user exists in the database and then verify the entered password
        // against the one stored in the database. If it is correct then login in user
        if let user = try await User.login(
            email: details.email,
            password: details.password,
            db: fluent.db()
        ) {
            // create session
            try context.sessions.setSession(user.requireID())
            // redirect to home page
            return .redirect(to: request.uri.queryParameters.get("from") ?? "/", type: .found)
        } else {
            // login failed return login HTML with failed comment
            var response = try HTML(
                title: "Dashboard",
                description: "Take control of your life with this wonderful todo list application.",
                content: "<h1>login</h1>"
            ).response(from: request, context: context)
            response.status = .unauthorized
            return response
        }
    }
    
    struct SignupDetails: Decodable {
        let name: String
        let email: String
        let password: String
    }
    
    /// Sign Up Page Content
    struct signUpContent {
        let error: String?
        
        func response() -> HTML {
            return HTML(
                title: "Sign Up",
                description: "Take control of your life with this wonderful todo list application.",
                content: """
                <form class="auth-form" action="/signup" method="post">
                    \(error != nil ? "<span class=\"error\"><b>Error</b>: \(error ?? "")</span>" : "")
                    <h1>Sign Up</h1>
                    <div class="form-group">
                        <label for="name">Name</label>
                        <input 
                            type="text" 
                            id="name" 
                            name="name" 
                            autocomplete="name"
                            required
                        >
                    </div>
                    <div class="form-group">
                        <label for="email">Email</label>
                        <input 
                            type="email" 
                            id="email" 
                            name="email"
                            required
                        >
                    </div>
                    <div class="form-group">
                        <label for="password">Password</label>
                        <input 
                            type="password" 
                            id="password" 
                            name="password"
                            autocomplete="new-password"
                            required
                        >
                    </div>
                    <div class="form-group">
                        <label for="password">Confirm Password</label>
                        <input 
                            type="password" 
                            id="password" 
                            name="password"
                            autocomplete="new-password"
                            required
                        >
                    </div>
                    <button class="primary" type="submit">Sign Up</button>
                    <a href="/login">Already have an account?</a>
                </form>
                """
            )
        }
    }
    
    /// Signup page
    @Sendable func signup(request: Request, context: Context) async throws -> HTML {
        let content = signUpContent(error: nil)
        return content.response()
    }
    
    /// Signup POST page
    @Sendable func signupDetails(request: Request, context: Context) async throws -> Response {
        let details = try await request.decode(as: SignupDetails.self, context: context)
        do {
            // create new user
            _ = try await User.create(
                name: details.name,
                email: details.email,
                password: details.password,
                db: self.fluent.db()
            )
            // redirect to login page
            return .redirect(to: "/login", type: .found)
        } catch let error as HTTPError {
            // if user creation throws a conflict ie the email is already being used by another user then return signup page with error message
            if error.status == .conflict {
                return try HTML(
                    title: "Sign Up",
                    description: "Take control of your life with this wonderful todo list application.",
                    content: signUpContent(error: error.localizedDescription).response().content
                )
                .response(from: request, context: context)
            } else {
                throw error
            }
        }
    }
}
