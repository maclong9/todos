# Swift Todos

## Write Documentation Here About

- [ ] MVC architecture
- [ ] Databases, Migrations & Repositries
- [ ] HTTP Requests, Repsonses and Context
- [ ] Templating Using Swift and the `HTML` Extension
- [ ] Running a Server `App` and `Application+build`
- [ ] Creting a Design System with CSS
- [ ] Client Side Updates with JS
- [ ] Testing Your Application `Tests`
- [ ] Deploying This Application

## TodoController

### Example Usage

```swift
let todoController = TodoController(
    fluent: app.fluent,
    sessionAuthenticator: UserSessionAuthenticator(userRepository: userRepo)
)

// Add routes to your application
app.group("api", "todos") { group in
    todoController.addRoutes(to: group)
}
```

### Creating and Managing Todos

Here's an example of how to interact with the todo endpoints:

```swift
// Create a new todo
let newTodo = try await client.post("api/todos") {
    CreateTodoRequest(title: "Buy groceries")
}

// Mark todo as completed
let updated = try await client.patch("api/todos/\(newTodo.id)") {
    EditTodoRequest(completed: true)
}
```
