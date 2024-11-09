import Bcrypt
import FluentKit
import Foundation
import Hummingbird
import HummingbirdAuth
import HummingbirdBasicAuth
import HummingbirdFluent
import NIOPosix

/// Database description of a user
final class User: Model, PasswordAuthenticatable, @unchecked Sendable {
  static let schema = "user"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "email")
  var email: String

  @Field(key: "name")
  var name: String

  @Field(key: "password")
  var passwordHash: String?

  @Children(for: \.$owner)
  var todos: [Todo]

  init() {}

  init(id: UUID? = nil, name: String, email: String, passwordHash: String) {
    self.id = id
    self.name = name
    self.email = email
    self.passwordHash = passwordHash
  }
}

extension User {
  var username: String { self.name }

  /// create a User in the db attached to request
  static func create(name: String, email: String, password: String, db: Database) async throws
    -> User
  {
    // check if user exists and if they don't then add new user
    let existingUser = try await User.query(on: db)
      .filter(\.$email == email)
      .first()

    // if user already exist throw conflict with descriptive message
    guard existingUser == nil else {
      throw HTTPError(.conflict, message: "Email address already in use")
    }

    // MARK: Check why this is done on a seperate thread
    // Encrypt password on a separate thread
    let passwordHash = try await NIOThreadPool.singleton.runIfActive {
      Bcrypt.hash(password, cost: 12)
    }

    // Create user and save to database
    let user = User(name: name, email: email, passwordHash: passwordHash)
    try await user.save(on: db)
    return user
  }

  /// Check user can login
  static func login(email: String, password: String, db: Database) async throws -> User? {
    // checks if user exists and stores password hash
    guard
      let user = try await User.query(on: db)
        .filter(\.$email == email)
        .first(),
      let passwordHash = user.passwordHash
    else {
      return nil
    }

    // MARK: Check why this is done on a seperate thread
    // checks entered password hash against stored password hash on different thread
    let verified = try await NIOThreadPool.singleton.runIfActive {
      Bcrypt.verify(password, hash: passwordHash)
    }

    return verified ? user : nil
  }
}

/// Create user request object decoded from HTTP body
struct CreateUserRequest: Decodable {
  let name: String
  let email: String
  let password: String

  init(name: String, email: String, password: String) {
    self.name = name
    self.email = email
    self.password = password
  }
}

/// User encoded into HTTP response
struct UserResponse: ResponseCodable {
  let id: UUID?

  init(id: UUID?) {
    self.id = id
  }

  init(from user: User) {
    self.id = user.id
  }
}
