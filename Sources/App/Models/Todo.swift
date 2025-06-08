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

  @Field(key: "url")
  var url: String?

  @Field(key: "completed")
  var isCompleted: Bool

  init() {}

  init(
    id: UUID? = nil, title: String, ownerID: User.IDValue,
    url: String? = nil,
    completed: Bool = false
  ) {
    self.id = id
    self.title = title
    self.url = url
    self.isCompleted = completed
    self.$owner.id = ownerID
  }

  func update(title: String? = nil, completed: Bool? = nil) {
    if let title = title {
      self.title = title
    }
    if let completed = completed {
      self.isCompleted = completed
    }
  }
}
