import FluentKit
import Foundation
import Hummingbird
import HummingbirdAuth
import HummingbirdFluent
import Logging
import NIO

/// CRUD routes for todos
struct TodoController {
  // Request context used by Todos routes.
  struct TodoContext: ChildRequestContext {
    var coreContext: CoreRequestContextStorage
    var user: User

    init(context: AppRequestContext) throws {
      self.coreContext = context.coreContext
      // if user identity doesn't exist then throw an unauthorized HTTP error
      self.user = try context.requireIdentity()
    }

    var requestDecoder: TodosAuthRequestDecoder {
      TodosAuthRequestDecoder()
    }
  }

  let fluent: Fluent
  let sessionAuthenticator: SessionAuthenticator<AppRequestContext, UserRepository>
  let logger: Logger

  func addRoutes(to group: RouterGroup<AppRequestContext>) {
    group
      .add(middleware: self.sessionAuthenticator)
      .group(context: TodoContext.self)
      .get(use: self.list)
      .get(":id", use: self.get)
      .post(use: self.create)
      .patch(":id", use: self.update)
      .delete(":id", use: self.deleteId)
  }

  /// List all todos created by current user
  @Sendable func list(_ request: Request, context: TodoContext) async throws
    -> [Todo]
  {
    try await context.user.$todos.get(on: self.fluent.db())
  }

  struct CreateTodoRequest: ResponseCodable {
    var title: String
  }

  /// Create new todo
  @Sendable func create(_ request: Request, context: TodoContext) async throws
    -> EditedResponse<
      Todo
    >
  {
    let todoRequest = try await request.decode(
      as: CreateTodoRequest.self, context: context)
    guard let host = request.head.authority else {
      throw HTTPError(.badRequest, message: "No host header")
    }
    let todo = try Todo(
      title: todoRequest.title, ownerID: context.user.requireID())
    let db = self.fluent.db()
    _ = try await todo.save(on: db)
    todo.isCompleted = false
    todo.url = "http://\(host)/api/todos/\(todo.id!)"
    try await todo.update(on: db)
    return .init(status: .created, response: todo)
  }

  /// Get todo
  @Sendable func get(_ request: Request, context: TodoContext) async throws
    -> Todo?
  {
    let id = try context.parameters.require("id", as: UUID.self)
    return try await Todo.query(on: self.fluent.db())
      .filter(\.$id == id)
      .with(\.$owner)
      .first()
  }

  struct EditTodoRequest: ResponseCodable {
    var title: String?
    var completed: Bool?
  }

  /// Edit todo
  @Sendable func update(_ request: Request, context: TodoContext) async throws
    -> Todo
  {
    let id = try context.parameters.require("id", as: UUID.self)
    let editTodo = try await request.decode(
      as: EditTodoRequest.self, context: context)
    let db = self.fluent.db()
    guard
      let todo = try await Todo.query(on: db)
        .filter(\.$id == id)
        .with(\.$owner)
        .first()
    else {
      throw HTTPError(.notFound)
    }
    guard todo.owner.id == context.user.id else {
      throw HTTPError(.unauthorized)
    }
    todo.update(title: editTodo.title, completed: editTodo.completed)
    try await todo.update(on: db)
    return todo
  }

  /// delete todo
  @Sendable func deleteId(_ request: Request, context: TodoContext)
    async throws
    -> HTTPResponse.Status
  {
    let id = try context.parameters.require("id", as: UUID.self)
    let db = self.fluent.db()
    guard
      let todo = try await Todo.query(on: db)
        .filter(\.$id == id)
        .with(\.$owner)
        .first()
    else {
      throw HTTPError(.notFound)
    }
    guard todo.owner.id == context.user.id else {
      throw HTTPError(.unauthorized)
    }
    try await todo.delete(on: db)
    return .ok
  }
}
