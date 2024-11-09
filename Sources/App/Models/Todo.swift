import FluentKit
import Foundation
import Hummingbird

/// Database description of a Todo
final class Todo: @unchecked Sendable, Model, ResponseCodable {
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

  init(id: UUID? = nil, title: String, ownerID: User.IDValue, completed: Bool = false) {
    self.id = id
    self.title = title
    self.completed = completed
    self.$owner.id = ownerID
  }

  // update function for editing todo items
  func update(title: String? = nil, completed: Bool? = nil) {
    if let title = title {
      self.title = title
    }
    if let completed = completed {
      self.completed = completed
    }
  }
}
