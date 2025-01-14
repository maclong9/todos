import Bcrypt
import FluentKit
import Foundation
import Hummingbird
import HummingbirdAuth
import HummingbirdBasicAuth
import HummingbirdFluent
import NIOPosix

/// A model representing a user in the database.
///
/// The `User` class handles user authentication and management, storing essential
/// user information and providing methods for user creation and authentication.
/// It conforms to `Model` for database operations and `PasswordAuthenticatable`
/// for authentication support.
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

    /// Creates a new user with the specified properties
    ///
    /// - Parameters:
    ///   - id: The optional UUID for the user. If nil, one will be generated
    ///   - name: The user's display name
    ///   - email: The user's email address
    ///   - passwordHash: The BCrypt-hashed password
    init(id: UUID? = nil, name: String, email: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash

    }
}

extension User {
    var username: String { self.name }

    /// Creates a new user in the database
    ///
    /// This method handles the complete user creation process, including:
    /// - Checking for existing users with the same email
    /// - Hashing the password
    /// - Saving the new user to the database
    ///
    /// - Parameters:
    ///   - name: The user's display name
    ///   - email: The user's email address
    ///   - password: The plain text password (will be hashed before storage)
    ///   - db: The database connection to use
    ///
    /// - Throws: `HTTPError.conflict` if the email is already in use
    /// - Returns: The newly created user
    static func create(name: String, email: String, password: String, db: Database) async throws
        -> User
    {
        let existingUser = try await User.query(on: db)
            .filter(\.$email == email)
            .first()

        guard existingUser == nil else {
            throw HTTPError(.conflict, message: "Email address already in use")
        }

        let passwordHash = try await NIOThreadPool.singleton.runIfActive {
            Bcrypt.hash(password, cost: 12)
        }

        let user = User(name: name, email: email, passwordHash: passwordHash)
        try await user.save(on: db)
        return user
    }

    /// Authenticates a user with email and password
    ///
    /// This method verifies the user's credentials by:
    /// - Finding the user by email
    /// - Verifying the provided password against the stored hash
    ///
    /// - Parameters:
    ///   - email: The user's email address
    ///   - password: The plain text password to verify
    ///   - db: The database connection to use
    ///
    /// - Returns: The authenticated user if successful, nil otherwise
    static func login(email: String, password: String, db: Database) async throws -> User? {
        guard
            let user = try await User.query(on: db)
                .filter(\.$email == email)
                .first(),
            let passwordHash = user.passwordHash
        else {
            return nil
        }

        let verified = try await NIOThreadPool.singleton.runIfActive {
            Bcrypt.verify(password, hash: passwordHash)
        }

        return verified ? user : nil
    }
}

/// A request object for creating new users
///
/// This struct defines the expected JSON structure for user creation requests
struct CreateUserRequest: Decodable {
    /// The user's display name
    let name: String
    /// The user's email address
    let email: String
    /// The user's plain text password
    let password: String

    /// Creates a new user creation request
    ///
    /// - Parameters:
    ///   - name: The user's display name
    ///   - email: The user's email address
    ///   - password: The user's plain text password
    init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        self.password = password
    }
}

/// A response object for user data
///
/// This struct defines the JSON structure for user responses,
/// currently only including the user's ID for security
struct UserResponse: ResponseCodable {
    /// The user's unique identifier
    let id: UUID?

    /// Creates a new user response
    ///
    /// - Parameter id: The user's unique identifier
    init(id: UUID?) {
        self.id = id
    }

    /// Creates a user response from a User model
    ///
    /// - Parameter user: The user model to create the response from
    init(from user: User) {
        self.id = user.id
    }
}
