import FluentKit
import Foundation
import Hummingbird
import HummingbirdAuth
import HummingbirdBasicAuth
import HummingbirdFluent
import Logging
import NIO

struct UserController {
  typealias Context = AppRequestContext
  let fluent: Fluent
  let sessionAuthenticator: SessionAuthenticator<Context, UserRepository>
  let logger: Logger

  /// Add routes for user controller
  func addRoutes(to group: RouterGroup<Context>) {
    group.post(use: self.create)
    group.group("login")
      .add(
        middleware: BasicAuthenticator(
          users: self.sessionAuthenticator.users)
      )
      .post(use: self.login)
    group.add(middleware: self.sessionAuthenticator)
      .get(use: self.current)
      .post("logout", use: self.logout)
  }

  /// Create new user
  /// Used in tests, as user creation is done by ``WebController.signupDetails``
  @Sendable func create(_ request: Request, context: Context) async throws
    -> EditedResponse<
      UserResponse
    >
  {
    let createUser = try await request.decode(
      as: CreateUserRequest.self, context: context)

    let user = try await User.create(
      name: createUser.name,
      email: createUser.email,
      password: createUser.password,
      db: self.fluent.db()
    )

    return .init(status: .created, response: UserResponse(from: user))
  }

  /// Login user and create session
  /// Used in tests, as user creation is done by ``WebController.loginDetails``
  @Sendable func login(_ request: Request, context: Context) async throws
    -> Response
  {
    guard let user = context.identity else {
      throw HTTPError(.unauthorized)
    }
    try context.sessions.setSession(user.requireID())
    return Response(
      status: .seeOther,
      headers: [.location: "/dashboard"]
    )
  }

  /// Login user and create session
  @Sendable func logout(_ request: Request, context: Context) async throws
    -> Response
  {
    context.sessions.clearSession()
    return .redirect(to: "/", type: .found)
  }

  /// Get current logged in user
  @Sendable func current(_ request: Request, context: Context) throws
    -> UserResponse
  {
    let user = try context.requireIdentity()
    return UserResponse(from: user)
  }
}
