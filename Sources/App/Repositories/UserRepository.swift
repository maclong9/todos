import FluentKit
import Foundation
import Hummingbird
import HummingbirdAuth
import HummingbirdBasicAuth
import HummingbirdFluent

// MARK: Figure out what Repository's are and what they are for
struct UserRepository: UserSessionRepository, UserPasswordRepository {
    typealias User = App.User
    typealias Session = UUID
    
    let fluent: Fluent
    
    /// Find user from session UUID
    ///
    /// - Parameters:
    ///   - session: The UUID for the current session
    ///   - context: Context containing the user session
    func getUser(from session: UUID, context: UserRepositoryContext) async throws -> User? {
        try await User.find(session, on: self.fluent.db())
    }
    
    /// Find user via email address
    ///
    ///  - Parameters:
    ///   - email: labeled`named` - a string containing the users email address
    ///   - context: Context containing the user session
    func getUser(named email: String, context: UserRepositoryContext) async throws -> User? {
        try await User.query(on: self.fluent.db())
            .filter(\.$email == email)
            .first()
    }
}
