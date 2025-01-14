import FluentKit

/// database migration for todo items
struct CreateTodo: AsyncMigration {
    func prepare(on database: Database) async throws {
        return try await database.schema("todos")
            .id()
            .field("title", .string, .required)
            .field("owner_id", .uuid, .required, .references("user", "id"))
            .field("completed", .bool, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        return try await database.schema("todos").delete()
    }
}
