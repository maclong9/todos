import WebUI

struct DashboardView: Document {
  let user: User
  let todos: [Todo]
  let successMessage: String?

  init(user: User, todos: [Todo], successMessage: String? = nil) {
    self.user = user
    self.todos = todos
    self.successMessage = successMessage
  }

  var path: String { "dashboard" }
  var metadata: Metadata {
    Metadata(
      from: TodoApp().metadata,
      title: "Dashboard - \(user.name)",
      description: "Manage your tasks and stay organized",
      themeColor: TodoApp().metadata.themeColor
    )
  }

  var head: String? {
    """
    <style>
    \(TodoApp.commonStyles)
    /* Dashboard Specific Styles */
    .dashboard-container {
        animation: fadeIn 0.3s ease-in-out;
        max-width: 800px;
        margin: 0 auto;
        padding: var(--spacing-6);
    }

    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(10px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .dashboard-header {
        display: flex;
        justify-content: space-between;
        align-items: end;
        margin-bottom: var(--spacing-6);
        padding-bottom: var(--spacing-4);
        border-bottom: 1px solid var(--border);

        @media(min-width: 768px) {
            align-items: center;
        }
    }

    .dashboard-title {
        color: var(--foreground);
        font-family: var(--font-sans);
        font-weight: 600;
        font-size: var(--font-size-2xl);
    }

    .user-info {
        display: flex;
        flex-direction: column;
        align-items: end;
        gap: var(--spacing-3);

        @media(min-width: 768px) {
            flex-direction: row;
            align-items: center;
        }
    }

    .user-name {
        color: var(--foreground);
        font-family: var(--font-sans);
        font-weight: 500;
        font-size: var(--font-size-sm);
    }

    .logout-button {
        transition: var(--transition-all);
        border-radius: var(--radius-md);
        background: transparent;
        color: var(--muted);
        padding: var(--spacing-2) var(--spacing-4);
        cursor: pointer;
        font-family: var(--font-sans);
        font-weight: 500;
        font-size: var(--font-size-sm);

        &:hover {
            background: var(--error);
            color: var(--foreground);
        }
    }

    .todo-form {
        margin-bottom: var(--spacing-6);
        padding: var(--spacing-4);
        background: var(--input);
        border: 1px solid var(--border);
        border-radius: var(--radius-md);
        display: flex;
        align-items: center;

        .todo-input {
            flex: 1;
            margin: 0;
            border-top-right-radius: 0;
            border-bottom-right-radius: 0;
            border-right: none;
        }

        button {
            border: 1px solid var(--border);
            border-top-left-radius: 0;
            border-bottom-left-radius: 0;
            margin: 0;
            padding: var(--spacing-3) var(--spacing-4);
            min-width: 50px;
        }
    }

    .todo-input {
        width: 100%;
        padding: var(--spacing-3);
        background: var(--background);
        border: 1px solid var(--border);
        border-radius: var(--radius-md);
        color: var(--foreground);
        font-family: var(--font-sans);
        font-size: var(--font-size-sm);
        margin-bottom: 0;

        &:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 2px rgba(153, 255, 228, 0.2);
        }
    }

    .todo-list {
        display: flex;
        flex-direction: column;
        gap: var(--spacing-3);
    }

    .todo-item {
        display: flex;
        align-items: center;
        gap: var(--spacing-3);
        padding: var(--spacing-4);
        background: var(--input);
        border: 1px solid var(--border);
        border-radius: var(--radius-md);
        transition: var(--transition-all);
        position: relative;
        overflow: hidden;

        &:hover {
            border-color: var(--primary);
            box-shadow: 0 0 0 1px rgba(153, 255, 228, 0.1);
        }

        &.completed {
            opacity: 0.7;
            background: linear-gradient(135deg, var(--input) 0%, rgba(153, 255, 228, 0.05) 100%);
        }

        &.editing {
            border-color: var(--primary);
            box-shadow: 0 0 0 2px rgba(153, 255, 228, 0.2);
        }
    }

    .todo-checkbox {
        padding: 0 !important;
        margin-bottom: 0 !important;
        flex-shrink: 0;
        width: 20px;
        height: 20px;
        appearance: none;
        -webkit-appearance: none;
        -moz-appearance: none;
        border: 2px solid var(--border);
        border-radius: 50%;
        cursor: pointer;
        transition: var(--transition-all);
        display: flex;
        align-items: center;
        justify-content: center;
        position: relative;
        background: var(--background);

        &:hover {
            border-color: var(--primary);
            transform: scale(1.05);
        }

        &:checked {
            background: var(--primary);
            border-color: var(--primary);
            animation: checkboxPulse 0.3s ease-out;
        }

        &:checked::after {
            content: '✓';
            color: var(--background);
            font-size: 12px;
            font-weight: bold;
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            animation: checkmarkAppear 0.2s ease-out 0.1s both;
        }
    }

    @keyframes checkboxPulse {
        0% { transform: scale(1); }
        50% { transform: scale(1.1); }
        100% { transform: scale(1); }
    }

    @keyframes checkmarkAppear {
        0% { opacity: 0; transform: translate(-50%, -50%) scale(0.5); }
        100% { opacity: 1; transform: translate(-50%, -50%) scale(1); }
    }

    .todo-title {
        flex-grow: 1;
        color: var(--foreground);
        font-family: var(--font-sans);
        font-size: var(--font-size-sm);
        overflow-wrap: break-word;
        line-height: 1.4;
        transition: var(--transition-all);
        cursor: pointer;
        padding: var(--spacing-1) var(--spacing-2);
        border-radius: var(--radius-sm);

        &:hover {
            background: rgba(153, 255, 228, 0.05);
        }

        &.completed {
            text-decoration: line-through;
            color: var(--muted);
        }

        &.editing {
            display: none;
        }
    }

    .todo-title-input {
        flex-grow: 1;
        background: var(--background);
        border: 1px solid var(--primary);
        border-radius: var(--radius-sm);
        color: var(--foreground);
        font-family: var(--font-sans);
        font-size: var(--font-size-sm);
        padding: var(--spacing-1) var(--spacing-2);
        margin: 0;
        display: none;

        &.editing {
            display: block;
        }

        &:focus {
            outline: none;
            box-shadow: 0 0 0 2px rgba(153, 255, 228, 0.2);
        }
    }

    .todo-actions {
        display: flex;
        gap: var(--spacing-1);
        flex-shrink: 0;
        opacity: 0;
        transition: var(--transition-all);
    }

    .todo-item:hover .todo-actions {
        opacity: 1;
    }

    .todo-button {
        transition: var(--transition-all);
        border-radius: var(--radius-sm);
        background: transparent;
        padding: var(--spacing-2);
        border: none;
        cursor: pointer;
        font-family: var(--font-sans);
        font-weight: 500;
        font-size: var(--font-size-sm);
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;

        &:hover {
            transform: scale(1.1);
        }
    }

    .todo-edit {
        color: var(--muted);

        &:hover {
            color: var(--foreground);
            background: rgba(153, 255, 228, 0.1);
        }
    }

    .todo-delete {
        color: var(--error);

        &:hover {
            background: rgba(255, 77, 77, 0.1);
            color: var(--error);
        }
    }

    .todo-save, .todo-cancel {
        display: none;
    }

    .todo-item.editing .todo-save,
    .todo-item.editing .todo-cancel {
        display: flex;
    }

    .todo-item.editing .todo-edit {
        display: none;
    }

    .todo-item.editing .todo-actions {
        opacity: 1;
    }

    .todo-save {
        color: var(--primary);

        &:hover {
            background: rgba(153, 255, 228, 0.1);
        }
    }

    .todo-cancel {
        color: var(--muted);

        &:hover {
            background: rgba(160, 160, 160, 0.1);
        }
    }

    .empty-state {
        text-align: center;
        padding: var(--spacing-8);
        color: var(--muted);
        font-family: var(--font-sans);
        font-size: var(--font-size-sm);
        background: var(--input);
        border: 1px dashed var(--border);
        border-radius: var(--radius-md);
    }

    .loading-indicator {
        opacity: 0.5;
        pointer-events: none;
        position: relative;
    }

    .loading-indicator::after {
        content: '';
        position: absolute;
        top: 50%;
        right: var(--spacing-4);
        width: 16px;
        height: 16px;
        border: 2px solid var(--border);
        border-top: 2px solid var(--primary);
        border-radius: 50%;
        animation: spin 1s linear infinite;
    }

    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
    </style>
    """
  }

  var scripts: [Script]? {
    [
      Script(attribute: .defer) {
        """
        let todosState = {
            todos: [],
            editingId: null,
            isLoading: false
        };

        // DOM utility functions
        function $(selector) {
            return document.querySelector(selector);
        }

        function $$(selector) {
            return document.querySelectorAll(selector);
        }

        // Loading state management
        function setLoading(element, isLoading) {
            if (isLoading) {
                element.classList.add('loading-indicator');
            } else {
                element.classList.remove('loading-indicator');
            }
        }

        // Fetch and display todos
        async function loadTodos() {
            const todoList = $('.todo-list');
            setLoading(todoList, true);
            
            try {
                const response = await fetch('/api/todos');
                if (!response.ok) throw new Error('Failed to fetch todos');
                
                todosState.todos = await response.json();
                renderTodos();
            } catch (error) {
                console.error('Error loading todos:', error);
                todoList.innerHTML = '<div class="empty-state">Failed to load todos. Please refresh the page.</div>';
            } finally {
                setLoading(todoList, false);
            }
        }

        // Render todos to DOM
        function renderTodos() {
            const todoList = $('.todo-list');

            if (todosState.todos.length === 0) {
                todoList.innerHTML = '<div class="empty-state">No todos yet. Add one above to get started!</div>';
                return;
            }

            todoList.innerHTML = todosState.todos.map(todo => `
                <div class="todo-item ${todo.isCompleted ? 'completed' : ''}" data-id="${todo.id}">
                    <input 
                        type="checkbox" 
                        class="todo-checkbox"
                        ${todo.isCompleted ? 'checked' : ''}
                        onchange="toggleTodo('${todo.id}', this.checked)"
                    >
                    <span class="todo-title ${todo.isCompleted ? 'completed' : ''}" 
                          onclick="startEditing('${todo.id}')">${escapeHtml(todo.title)}</span>
                    <input type="text" 
                           class="todo-title-input" 
                           value="${escapeHtml(todo.title)}"
                           onkeydown="handleEditKeydown(event, '${todo.id}')"
                           onblur="setTimeout(() => cancelEditing('${todo.id}'), 150)">
                    <div class="todo-actions">
                        <button class="todo-button todo-edit" onclick="startEditing('${todo.id}')" title="Edit">✎</button>
                        <button class="todo-button todo-save" onclick="saveEdit('${todo.id}')" title="Save">✓</button>
                        <button class="todo-button todo-cancel" onclick="cancelEditing('${todo.id}')" title="Cancel">✕</button>
                        <button class="todo-button todo-delete" onclick="deleteTodo('${todo.id}')" title="Delete">×</button>
                    </div>
                </div>
            `).join('');
        }

        // Escape HTML to prevent XSS
        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }

        // Add new todo
        async function createTodo() {
            const input = $('#new-todo-input');
            const title = input.value.trim();
            
            if (!title) return;

            setLoading(input.parentElement, true);
            
            try {
                const response = await fetch('/api/todos', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ title })
                });

                if (!response.ok) throw new Error('Failed to create todo');

                const newTodo = await response.json();
                todosState.todos.push(newTodo);
                input.value = '';
                renderTodos();
            } catch (error) {
                console.error('Error creating todo:', error);
                alert('Failed to create todo. Please try again.');
            } finally {
                setLoading(input.parentElement, false);
            }
        }

        // Toggle todo completion
        async function toggleTodo(id, isCompleted) {
            const todoItem = $(`[data-id="${id}"]`);
            setLoading(todoItem, true);
            
            try {
                const response = await fetch(`/api/todos/${id}`, {
                    method: 'PATCH',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ completed: isCompleted })
                });

                if (!response.ok) throw new Error('Failed to update todo');

                const updatedTodo = await response.json();
                const todoIndex = todosState.todos.findIndex(t => t.id === id);
                if (todoIndex !== -1) {
                    todosState.todos[todoIndex] = updatedTodo;
                    renderTodos();
                }
            } catch (error) {
                console.error('Error updating todo:', error);
                // Revert checkbox state
                const checkbox = todoItem.querySelector('.todo-checkbox');
                checkbox.checked = !isCompleted;
                alert('Failed to update todo. Please try again.');
            } finally {
                setLoading(todoItem, false);
            }
        }

        // Start editing a todo
        function startEditing(id) {
            // Cancel any existing edit
            if (todosState.editingId) {
                cancelEditing(todosState.editingId);
            }

            todosState.editingId = id;
            const todoItem = $(`[data-id="${id}"]`);
            const titleSpan = todoItem.querySelector('.todo-title');
            const titleInput = todoItem.querySelector('.todo-title-input');
            const editButtons = todoItem.querySelectorAll('.editing');
            const normalButtons = todoItem.querySelectorAll('.todo-edit');

            todoItem.classList.add('editing');
            titleSpan.classList.add('editing');
            titleInput.classList.add('editing');
            editButtons.forEach(btn => btn.classList.add('editing'));
            normalButtons.forEach(btn => btn.style.display = 'none');

            titleInput.focus();
            titleInput.select();
        }

        // Cancel editing
        function cancelEditing(id) {
            if (todosState.editingId !== id) return;

            todosState.editingId = null;
            const todoItem = $(`[data-id="${id}"]`);
            const titleSpan = todoItem.querySelector('.todo-title');
            const titleInput = todoItem.querySelector('.todo-title-input');
            const editButtons = todoItem.querySelectorAll('.editing');
            const normalButtons = todoItem.querySelectorAll('.todo-edit');

            todoItem.classList.remove('editing');
            titleSpan.classList.remove('editing');
            titleInput.classList.remove('editing');
            editButtons.forEach(btn => btn.classList.remove('editing'));
            normalButtons.forEach(btn => btn.style.display = 'flex');

            // Reset input value to original
            const originalTodo = todosState.todos.find(t => t.id === id);
            if (originalTodo) {
                titleInput.value = originalTodo.title;
            }
        }

        // Save edit
        async function saveEdit(id) {
            const todoItem = $(`[data-id="${id}"]`);
            const titleInput = todoItem.querySelector('.todo-title-input');
            const newTitle = titleInput.value.trim();
            console.log({ todoItem, titleInput, newTitle, id });

            if (!newTitle) {
                alert('Todo title cannot be empty');
                titleInput.focus();
                return;
            }

            const originalTodo = todosState.todos.find(t => t.id === id);
            if (originalTodo && originalTodo.title === newTitle) {
                cancelEditing(id);
                return;
            }

            setLoading(todoItem, true);

            try {
                const response = await fetch(`/api/todos/${id}`, {
                    method: 'PATCH',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ title: newTitle })
                });

                if (!response.ok) throw new Error('Failed to update todo');

                const updatedTodo = await response.json();
                const todoIndex = todosState.todos.findIndex(t => t.id === id);
                if (todoIndex !== -1) {
                    todosState.todos[todoIndex] = updatedTodo;
                }

                cancelEditing(id);
                renderTodos();
            } catch (error) {
                console.error('Error updating todo:', error);
                alert('Failed to update todo. Please try again.');
            } finally {
                setLoading(todoItem, false);
            }
        }

        // Handle keyboard events during editing
        function handleEditKeydown(event, id) {
            if (event.key === 'Enter') {
                saveEdit(id);
            } else if (event.key === 'Escape') {
                cancelEditing(id);
            }
        }

        // Delete todo
        async function deleteTodo(id) {
            if (!confirm('Are you sure you want to delete this todo?')) return;

            const todoItem = $(`[data-id="${id}"]`);
            setLoading(todoItem, true);

            try {
                const response = await fetch(`/api/todos/${id}`, { method: 'DELETE' });
                
                if (!response.ok) throw new Error('Failed to delete todo');

                todosState.todos = todosState.todos.filter(t => t.id !== id);
                renderTodos();
            } catch (error) {
                console.error('Error deleting todo:', error);
                alert('Failed to delete todo. Please try again.');
            } finally {
                setLoading(todoItem, false);
            }
        }

        // Handle form submission for new todos
        function handleNewTodoKeydown(event) {
            if (event.key === 'Enter') {
                createTodo();
            }
        }

        // Initialize app
        document.addEventListener('DOMContentLoaded', () => {
            loadTodos();
            
            // Setup event listeners
            const newTodoInput = $('#new-todo-input');
            if (newTodoInput) {
                newTodoInput.addEventListener('keydown', handleNewTodoKeydown);
            }
        });

        // Expose functions globally for onclick handlers
        window.createTodo = createTodo;
        window.toggleTodo = toggleTodo;
        window.startEditing = startEditing;
        window.cancelEditing = cancelEditing;
        window.saveEdit = saveEdit;
        window.handleEditKeydown = handleEditKeydown;
        window.deleteTodo = deleteTodo;
        """
      }
    ]
  }

  var body: some HTML {
    LayoutView {
      Stack(classes: ["dashboard-container"]) {
        // Dashboard Header
        Stack(classes: ["dashboard-header"]) {
          Heading(.title, classes: ["dashboard-title"]) { "My Todos" }
          Stack(classes: ["user-info"]) {
            Text(classes: ["user-name"]) { "Welcome, \(user.name)" }
            Form(action: "/api/users/logout", method: .post) {
              Button(type: .submit, classes: ["logout-button"]) {
                "Logout"
              }
            }
          }
        }

        // Success message
        if let message = successMessage {
          Stack(classes: ["success-message"]) {
            Text { message }
          }
        }

        // Todo Form
        Stack(classes: ["todo-form"]) {
          Input(
            name: "title",
            type: .text,
            placeholder: "What needs to be done?",
            required: true,
            id: "new-todo-input",
            classes: ["todo-input"]
          )
          Button(onClick: "createTodo()", classes: [""]) { "+" }
        }

        // Todo List
        Stack(classes: ["todo-list"]) {
          // Content will be populated by JavaScript
        }
      }
    }
  }
}
