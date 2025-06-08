import FluentKit

struct CreateUser: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema("user")
      .id()
      .field("name", .string, .required)
      .field("email", .string, .required)
      .field("password", .string)
      .unique(on: "email")
      .create()
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema("user").delete()
  }
}
