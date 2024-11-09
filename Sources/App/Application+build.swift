import FluentSQLiteDriver
import Foundation
import Hummingbird
import HummingbirdAuth
import HummingbirdCompression
import HummingbirdFluent

public protocol AppArguments {
    var inMemoryDatabase: Bool { get }
    var migrate: Bool { get }
    var hostname: String { get }
    var port: Int { get }
}

func buildApplication(_ arguments: some AppArguments) async throws -> some ApplicationProtocol {
    let logger = Logger(label: "swift-todos")
    let fluent = Fluent(logger: logger)
    
    // add sqlite database
    if arguments.inMemoryDatabase {
        fluent.databases.use(.sqlite(.memory), as: .sqlite)
    } else {
        fluent.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    }
    
    // add migrations
    await fluent.migrations.add(CreateUser())
    await fluent.migrations.add(CreateTodo())
    
    let fluentPersist = await FluentPersistDriver(fluent: fluent)
    
    // migrate
    if arguments.migrate || arguments.inMemoryDatabase {
        try await fluent.migrate()
    }
    let userRepository = UserRepository(fluent: fluent)
    
    // ensure working directory is correct
    assert(FileManager.default.fileExists(atPath: "Public/styles.css"), "Set your working directory to the root folder of this example to get it to work")
    
    // router
    let router = Router(context: AppRequestContext.self)
    
    // add logging middleware
    router.addMiddleware {
        LogRequestsMiddleware(.info)
        ResponseCompressionMiddleware(minimumResponseSizeToCompress: 256)
        FileMiddleware(logger: logger)
        CORSMiddleware(
            allowOrigin: .originBased,
            allowHeaders: [.contentType],
            allowMethods: [.get, .options, .post, .delete, .patch]
        )
        SessionMiddleware(storage: fluentPersist)
    }
    
    // add health check route
    router.get("/health") { _, _ in
        return HTTPResponse.Status.ok
    }
    
    // add authenticator
    let sessionAuthenticator = SessionAuthenticator(users: userRepository, context: AppRequestContext.self)
    
    // add api routes
    TodoController(fluent: fluent, sessionAuthenticator: sessionAuthenticator).addRoutes(to: router.group("api/todos"))
    UserController(fluent: fluent, sessionAuthenticator: sessionAuthenticator).addRoutes(to: router.group("api/users"))
    WebController(fluent: fluent, sessionAuthenticator: sessionAuthenticator).addRoutes(to: router)
    
    var app = Application(
        router: router,
        configuration: .init(address: .hostname(arguments.hostname, port: arguments.port))
    )
    app.addServices(fluent, fluentPersist)
    return app
}
