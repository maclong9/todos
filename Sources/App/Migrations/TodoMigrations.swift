import FluentKit

struct CreateTodo: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema("todos")
      .id()
      .field("title", .string, .required)
      .field("owner_id", .uuid, .required, .references("user", "id"))
      .field("completed", .bool, .required)
      .field("url", .string)
      .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema("todos").delete()
  }
}
