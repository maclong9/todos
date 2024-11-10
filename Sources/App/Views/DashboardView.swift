/**
 A view that displays the main application interface for authenticated users.
 
 Renders a personalized dashboard containing:
 - User welcome message and settings
 - Todo creation form
 - Interactive list of user's todos
 - Account management options
 
 - Parameters:
    - user: The currently authenticated user
    - todos: Array of user's todo items
    - error: Optional error message to display
 */
struct DashboardView {
  let user: User
  let todos: [Todo]
  let error: String?

  init(user: User, todos: [Todo], error: String? = nil) {
    self.user = user
    self.todos = todos
    self.error = error
  }

  func header() -> String {
    """
    <header>
        <h1>Welcome Back, \(user.name)</h1>
        <div class="btn-group">
            <button class="unstyle" onclick="settings.showModal()">
                ⚙️
                <span class="popover">Settings</span>
            </button>
            <button class="unstyle" onclick="TodoDashboard.logout()" aria-label="logout">
                🚪
                <span class="popover">Logout</span>
            </button>
        </div>
        <dialog id="settings">
            \(AuthView(action: .updateProfile).render())
        </dialog>
        <dialog id="deletion" class="surface small">
            <h2>Are you sure?</h2>
            <p>
               This action is final and cannot be reversed. <br />
               You will not be able to recover your account later.
            </p>
            <form class="btn-group" action="delete-account">
                <button type="button" onclick="deletion.close()">Cancel</button>
                <button class="destructive" type="submit">Delete Account</button>
            </form>
        </dialog>
    </header>
    """
  }

  func form() -> String {
    """
    <form class="todo-form">
        <div class="form-group">
            <label for="title">Add a Todo</label>
            <div class="inputs">
                <input 
                    type="text" 
                    id="title" 
                    name="title"
                    placeholder="What do you want to achieve?"
                    required
                >
                <input class="btn" type="submit" value="➕" />
            </div>
        </div>
    </form>      
    """
  }

  func list() -> String {
    if todos.isEmpty {
      return "<p>You have nothing todo...</p>"
    }

    let todoItems = todos.map { todo in
      """
      <li class="todo-item \(todo.completed ? "completed" : "")" data-id="\(todo.id!.description)">                
          <input 
              type="checkbox" 
              class="todo-checkbox" 
              \(todo.completed ? "checked" : "")
              aria-label="Mark '\(todo.title)' as \(todo.completed ? "incomplete" : "complete")"
          >
          <input 
              type="text" 
              class="todo-title" 
              value="\(todo.title)"
              aria-label="Todo title"
          >
          <button class="todo-action unstyle" aria-label="delete todo">🗑️</button>
      </li>
      """
    }.joined(separator: "\n")

    return """
      <ul class="todo-list">
          \(todoItems)
      </ul>
      """
  }

  func render() -> String {
    let errorMessage = error.map { "<div class='error'>\($0)</div>" } ?? ""

    return """
      <section class="dashboard">
          \(header())
          <main>
              \(errorMessage)
              \(form())
              <div class="list-container">
                  \(list())
              </div>
          </main>
      </section>
      <script src="dashboard.js"></script>
      """
  }
}
