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
struct UserController {
    typealias Context = AppRequestContext
    let fluent: Fluent
    let sessionAuthenticator: SessionAuthenticator<Context, UserRepository>

    /// Add routes for user controller
    func addRoutes(to group: RouterGroup<Context>) {
        group.post(use: self.create)
        group.group("login")
            .add(middleware: BasicAuthenticator(users: self.sessionAuthenticator.users))
            .post(use: self.login)
        group.add(middleware: self.sessionAuthenticator)
            .get(use: self.current)
            .post("logout", use: self.logout)
    }

    /// Creates a new user account
    ///
    /// This endpoint is primarily used in tests, as user creation is typically handled
    /// by the web interface through ``ViewController.signupDetails``.
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
            db: self.fluent.db()
        )

        return .init(status: .created, response: UserResponse(from: user))
    }

    /// Authenticates a user and creates a new session
    ///
    /// This endpoint is primarily used in tests, as user creation is typically handled
    /// by the web interface through ``ViewController.signupDetails``.
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

    /// Logout user
    @Sendable func logout(_ request: Request, context: Context) async throws -> HTTPResponse.Status
    {
        context.sessions.clearSession()
        return .ok
    }

    /// Get current logged in user
    @Sendable func current(_ request: Request, context: Context) throws -> UserResponse {
        let user = try context.requireIdentity()
        return UserResponse(from: user)
    }
}
