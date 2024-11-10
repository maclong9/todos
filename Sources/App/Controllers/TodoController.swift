import FluentKit
import Foundation
import Hummingbird
import HummingbirdAuth
import HummingbirdFluent
import NIO

/// A controller that manages todo-related operations and routing
///
/// The `TodoController` provides CRUD operations for todo items, ensuring that users can only
/// access and modify their own todos. It handles authentication and provides a Fluent ORM interface
/// for interacting with the todo database.
///
/// ## Overview
/// The controller provides the following main functionalities:
/// - Listing all todos for the current user
/// - Creating new todos
/// - Updating existing todos
/// - Deleting todos
/// - Retrieving individual todos
///
/// ## Topics
/// ### Request Handling
/// - ``list(_:context:)``
/// - ``get(_:context:)``
/// - ``create(_:context:)``
/// - ``update(_:context:)``
/// - ``delete(_:context:)``
///
/// ### Context Types
/// - ``TodoContext``
///
/// ### Request Types
/// - ``CreateTodoRequest``
/// - ``EditTodoRequest``
///
/// ### Related Types
/// - ``Todo``
/// - ``User``
/// - ``AppRequestContext``
struct TodoController {
    /// A context type that provides access to the authenticated user and core request context
    ///
    /// This type is used to ensure that all todo operations have access to the authenticated user.
    struct TodoContext: ChildRequestContext {
        var coreContext: CoreRequestContextStorage
        var user: User

        init(context: AppRequestContext) throws {
            self.coreContext = context.coreContext
            self.user = try context.requireIdentity()
        }

        var requestDecoder: TodosAuthRequestDecoder {
            TodosAuthRequestDecoder()
        }
    }

    let fluent: Fluent
    let sessionAuthenticator: SessionAuthenticator<AppRequestContext, UserRepository>

    /// Adds todo-related routes to the specified router group
    /// - Note: All routes will be protected by session authentication
    func addRoutes(to group: RouterGroup<AppRequestContext>) {
        group
            .add(middleware: self.sessionAuthenticator)
            .group(context: TodoContext.self)
            .get(use: self.list)
            .get(":id", use: self.get)
            .post(use: self.create)
            .patch(":id", use: self.update)
            .delete(":id", use: self.delete)
    }

    /// Lists all todos created by the current user
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request
    ///   - context: The todo context containing the authenticated user
    /// - Returns: An array of todos belonging to the current user
    /// - Throws: An error if the database operation fails or the user ID is missing
    @Sendable func list(_ request: Request, context: TodoContext) async throws -> [Todo] {
        return try await context.user.$todos.get(on: self.fluent.db())
    }

    /// Retrieves a specific todo by its ID
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request
    ///   - context: The todo context containing the authenticated user
    /// - Returns: The requested todo if found, nil otherwise
    /// - Throws: An error if the todo ID is missing, if the todo is not found, if the user is not authorized to get the todo, or if there's a database error
    @Sendable func get(_ request: Request, context: TodoContext) async throws -> Todo? {
        let id = try context.parameters.require("id", as: UUID.self)

        return try await Todo.query(on: self.fluent.db())
            .filter(\.$id == id)
            .with(\.$owner)  // MARK: Where does $owner come from?
            .first()
    }

    /// Request structure for creating a new todo item
    struct CreateTodoRequest: ResponseCodable {
        var title: String
    }

    /// Create a new todo for the current user
    ///
    /// - parameters:
    ///   - request: The incoming HTTP request
    ///   - context: The todo context containing the authenticated user
    /// - Returns: The newly created todo with a HTTP Status of created
    /// - Throws: An error if the request body cannot be decoded, user ID is missing or there's a database error
    @Sendable func create(_ request: Request, context: TodoContext) async throws -> EditedResponse<
        Todo
    > {
        let todoRequest = try await request.decode(as: CreateTodoRequest.self, context: context)
        let todo = try Todo(
            title: todoRequest.title,
            ownerID: context.user.requireID(),
            completed: false
        )

        let db = self.fluent.db()
        _ = try await todo.save(on: db)

        return .init(status: .created, response: todo)
    }

    /// Request structure for updating an existing todo item
    struct EditTodoRequest: ResponseCodable {
        var title: String?
        var completed: Bool?
    }

    /// Update an existing todo for the current user
    ///
    /// This type defines the optional fields that can be updated on a todo.
    /// Any field that is `nil` will not be modified during the update.
    ///
    /// - parameters:
    ///   - request: The incoming HTTP request
    ///   - context: The todo context containing the authenticated user
    /// - Returns: The update todo item
    /// - Throws: An error if the todo ID is missing, if the todo is not found, if the user is not authorized to update the todo, or if there's a database error
    @Sendable func update(_ request: Request, context: TodoContext) async throws -> Todo {
        let id = try context.parameters.require("id", as: UUID.self)
        let editTodo = try await request.decode(as: EditTodoRequest.self, context: context)
        let db = self.fluent.db()

        guard
            let todo = try await Todo.query(on: db)
                .filter(\.$id == id)
                .with(\.$owner)
                .first()
        else {
            throw HTTPError(.notFound)
        }

        guard todo.owner.id == context.user.id else { throw HTTPError(.unauthorized) }
        todo.update(title: editTodo.title, completed: editTodo.completed)
        try await todo.update(on: db)
        return todo
    }

    /// Delete an existing todo for the current user by its ID
    ///
    /// - parameters:
    ///   - request: The incoming HTTP request
    ///   - context: The todo context containing the authenticated user
    /// - Returns: A HTTP status code indicating successful deletion (`.ok`)
    /// - Throws: An error if the todo ID is missing, if the todo is not found, if the user is not authorized to delete the todo, or if there's a database error
    @Sendable func delete(_ request: Request, context: TodoContext) async throws
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

        guard todo.owner.id == context.user.id else { throw HTTPError(.unauthorized) }
        try await todo.delete(on: db)
        return .ok
    }
}
