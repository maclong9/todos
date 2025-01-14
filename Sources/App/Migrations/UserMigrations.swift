import FluentKit

/// database migration for users
struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user")
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("password", .string)
            .unique(on: "email")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user").delete()
    }
}
