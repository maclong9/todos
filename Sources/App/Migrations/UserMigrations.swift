import FluentKit

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user")
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("verified", .bool)
            .field("password", .string)
            .field("reset_token", .string)
            .field("reset_token_expires", .datetime)
            .unique(on: "email")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user").delete()
    }
}
