struct DashboardView {
    let user: User
    let todos: [Todo]
    
    func render() -> String {
        return """
        <section class="dashboard">
            <header>
                <h1>Welcome Back, \(user.name)</h1>
                <button class="unstyle" onclick="settings.showModal()">⚙️</button>
                <dialog id="settings">
                    \(AuthView(action: .updateProfile).render())
                </dialog>
                <dialog id="deletion" class="surface">
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
            <main>
                <form class="todo-form" action="/api/todos" method="post">
                    <div class="form-group">
                        <label for="email">Add a Todo</label>
                        <div class="inputs">
                            <input 
                                type="text" 
                                id="new-todo" 
                                name="new-todo"
                                placeholder="What do you want to achieve?"
                                required
                            >
                            <input class="btn" type="submit" value="+" />
                        </div>
                    </div>
                </form>
            </main>
        </section>
        """
    }
}
