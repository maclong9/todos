import FluentKit
import Foundation
import Hummingbird
import HummingbirdAuth
import HummingbirdBasicAuth
import HummingbirdFluent
import NIO

/// A controller that manages user authentication and account operations
///
/// The `UserController` handles user registration, authentication, and session management.
/// It provides endpoints for creating new users, logging in, logging out, and retrieving
/// the current user's information.
///
/// ## Overview
/// The controller supports:
/// - User registration
/// - User authentication
/// - Session management
/// - Current user information retrieval
///
/// ## Topics
/// ### User Operations
/// - ``create(_:context:)``
/// - ``login(_:context:)``
/// - ``logout(_:context:)``
/// - ``current(_:context:)``
///
/// ### Related Types
///  - ``User``
///  - ``AppRequestContext``
struct UserController {
    typealias Context = AppRequestContext
    let fluent: Fluent
    let sessionAuthenticator: SessionAuthenticator<Context, UserRepository>

    /// Adds authentication and user-related routes to the specified router group
    ///
    /// - Parameter group: The router group to add routes to
    /// - Note: The login route is protected by basic authentication
    /// - Note: The current user and logout routes are protected by session authentication
    func addRoutes(to group: RouterGroup<Context>) {
        group.post(use: create)
        group.group("login")
            .add(middleware: BasicAuthenticator(users: sessionAuthenticator.users))
            .post(use: login)
        group.add(middleware: sessionAuthenticator)
            .get(use: current)
            .post("logout", use: logout)
    }

    /// Creates a new user account
    ///
    /// This endpoint is primarily used in tests,
    /// as user creation is typically handled ``ViewController/signupDetails(request:context:)``
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request
    ///   - context: The application context
    /// - Returns: A response containing the created user's information
    /// - Throws: An error if user creation fails
    @Sendable func create(_ request: Request, context: Context) async throws -> EditedResponse<
        UserResponse
    > {
        let createUser = try await request.decode(as: CreateUserRequest.self, context: context)

        let user = try await User.create(
            name: createUser.name,
            email: createUser.email,
            password: createUser.password,
            db: fluent.db()
        )

        return .init(status: .created, response: UserResponse(from: user))
    }

    /// Authenticates a user and creates a new session
    ///
    /// This endpoint is primarily used in tests, as user creation is typically handled
    /// by the web interface through ``ViewController/loginDetails(request:context:)``.
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request
    ///   - context: The application context
    /// - Returns: An HTTP status indicating success
    /// - Throws: An unauthorized error if authentication fails
    @Sendable func login(_ request: Request, context: Context) async throws -> HTTPResponse.Status {
        guard let user = context.identity else { throw HTTPError(.unauthorized) }
        try context.sessions.setSession(user.requireID())
        return .ok
    }

    /// Ends the current users session
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request
    ///   - context: The application context
    /// - Returns: An HTTP status indicating success
    /// - Throws: Errors from the session clearing operation
    @Sendable func logout(_ request: Request, context: Context) async throws -> HTTPResponse.Status {
        context.sessions.clearSession()
        return .ok
    }

    /// Ends the current users session
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request
    ///   - context: The application context
    /// - Returns: The currently authenticated `User`
    /// - Throws: An unauthorized error if user is not signed in
    @Sendable func current(_ request: Request, context: Context) throws -> UserResponse {
        let user = try context.requireIdentity()
        return UserResponse(from: user)
    }
}
