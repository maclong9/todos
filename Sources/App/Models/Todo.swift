import FluentKit
import Foundation
import Hummingbird

/// A model representing a todo item in the database.
///
/// The `Todo` class represents a single todo item with properties for tracking its state
/// and ownership. It conforms to `Model` for database operations and `ResponseCodable`
/// for HTTP encoding/decoding.
final class Todo: @unchecked Sendable, Model, ResponseCodable {
  /// The database table name for todos
  static let schema = "todos"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "title")
  var title: String

  @Parent(key: "owner_id")
  var owner: User

  @Field(key: "completed")
  var completed: Bool

  init() {}

  /// Creates a new todo item with the specified properties
  ///
  /// - Parameters:
  ///   - id: The optional UUID for the todo item. If nil, one will be generated
  ///   - title: The title or description of the todo item
  ///   - ownerID: The ID of the user who owns this todo
  ///   - completed: The completion status of the todo, defaults to `false`
  init(id: UUID? = nil, title: String, ownerID: User.IDValue, completed: Bool = false) {
    self.id = id
    self.title = title
    self.completed = completed
    self.$owner.id = ownerID
  }

  /// Updates the todo item with new values
  ///
  /// This method allows partial updates of the todo item, only modifying
  /// the fields that are provided
  ///
  /// - Parameters:
  ///   - title: The new title for the todo item, if provided
  ///   - completed: The new completion status, if provided
  func update(title: String? = nil, completed: Bool? = nil) {
    if let title = title {
      self.title = title
    }
    if let completed = completed {
      self.completed = completed
    }
  }
}
