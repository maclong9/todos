struct DashboardView {
    let user: User
    let todos: [Todo]
    
    func render() -> String {
        print(todos)
        
        return """
        <section class="dashboard">
            <header>
                <h1>Welcome Back, \(user.name)</h1>
                <button onclick="modal.show()">Settings</button>
                <dialog class="surface">
                    <h1>Settings</h1>
                    <p>Edit your user information here</p>
                    <form method="dialog">
                        <button>Cancel</button>
                        <button class="primary">Save</button>
                    </form>
                </dialog>
            </header>
            <main>
                <form class="todo-form" action="/api/todos" method="post">
                    <div class="form-group">
                        <label for="email">Email</label>
                        <input 
                            type="text" 
                            id="new-todo" 
                            name="new-todo"
                            placeholder="What do you want to achieve?"
                            required
                        >
                    </div>
                </form>
                <ul class="todos-list">
                    <li>
                        <span>Todo Item 1</span>
                        <input type="checkbox" name="complete" />
                        <button>Delete</button>
                    </li>
                </ul>
            </main>
        </section>
        """
    }
}
