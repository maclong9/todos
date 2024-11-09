// Main dashboard container element @type {HTMLElement}
const dashboard = document.querySelector('.dashboard');
// Form element for creating new todos @type {HTMLFormElement}
const todoForm = document.querySelector('.todo-form');
// @type {HTMLElement}
const main = document.querySelector('.dashboard main');


/**
 * Handles user logout
 * @returns {Promise<void>}
 * @throws {Error} When the logout request fails
 */
async function logout() {
    try {
        const response = await fetch('/api/users/logout', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        });
        
        if (response.ok) {
            window.location.href = '/';
        }
    } catch (error) {
        console.error('Failed to logout:', error);
    }
}

/**
 * Handles the submission of new todo items
 * @param {Event} event - The form submission event
 * @returns {Promise<void>}
 */
todoForm.addEventListener('submit', async (event) => {
    event.preventDefault();
    const titleInput = document.getElementById('title');
    const title = titleInput.value.trim();
    
    if (!title) return;
    
    try {
        const response = await fetch('/api/todos', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ title })
        });

        if (!response.ok) throw new Error('Failed to add todo');

        const todo = await response.json();
        updateTodoList();
        titleInput.value = '';
    } catch (error) {
        console.error('Failed to add todo:', error);
    }
});

/**
 * Handles click events within the dashboard using event delegation
 * @param {Event} event - The click event
 * @returns {Promise<void>}
 */
dashboard.addEventListener('click', async (event) => {
    const target = event.target;

    if (target.matches('.todo-checkbox')) {
        event.preventDefault();
        const todoItem = target.closest('.todo-item');
        if (!todoItem) return;

        const todoId = todoItem.dataset.id;
        const checked = target.checked;

        try {
            await fetch(`/api/todos/${todoId}`, {
                method: 'PATCH',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ completed: checked })
            });
            
            target.checked = checked;
            todoItem.classList.toggle('completed', checked);
        } catch (error) {
            console.error('Failed to update todo:', error);
            target.checked = !checked;
        }
    }

    if (target.matches('.delete-todo')) {
        event.preventDefault();
        const todoItem = target.closest('.todo-item');
        if (!todoItem) return;

        const todoId = todoItem.dataset.id;
        
        try {
            await fetch(`/api/todos/${todoId}`, {
                method: 'DELETE',
                headers: { 'Content-Type': 'application/json' }
            });
            
            todoItem.remove();
            if (main.querySelectorAll('.todo-item').length === 0) {
                updateEmptyState();
            }
        } catch (error) {
            console.error('Failed to delete todo:', error);
        }
    }
});

/**
 * Updates the todo list UI with current todos from the server
 * @returns {Promise<void>}
 */
async function updateTodoList() {
    try {
        const response = await fetch('/api/todos');
        /** @type {Todo[]} */
        const todos = await response.json();
        
        if (todos.length === 0) {
            main.innerHTML = `
                ${todoForm.outerHTML}
                <p>You have nothing todo...</p>
            `;
            return;
        }

        const todoList = document.createElement('ul');
        todoList.className = 'todo-list';
        
        todos.forEach(todo => {
            const li = document.createElement('li');
            li.className = `todo-item ${todo.completed ? 'completed' : ''}`;
            li.dataset.id = todo.id;
            li.innerHTML = `
                <input type="checkbox" class="todo-checkbox" ${todo.completed ? 'checked' : ''}>
                <span class="todo-title">${escapeHtml(todo.title)}</span>
                <button class="delete-todo unstyle" aria-label="delete todo">🗑️</button>
            `;
            todoList.appendChild(li);
        });

        main.innerHTML = '';
        main.appendChild(todoForm);
        main.appendChild(todoList);
    } catch (error) {
        console.error('Failed to update todo list:', error);
    }
}

/**
 * Updates the UI to show empty state when no todos exist
 * @returns {void}
 */
function updateEmptyState() {
    const todoList = main.querySelector('.todo-list');
    if (todoList) {
        todoList.remove();
    }
    main.insertAdjacentHTML('beforeend', '<p>You have nothing todo...</p>');
}

/**
 * Escapes HTML special characters to prevent XSS attacks
 * @param {string} unsafe - The string containing potentially unsafe HTML
 * @returns {string} The escaped safe HTML string
 */
function escapeHtml(unsafe) {
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

// Initial load
document.addEventListener('DOMContentLoaded', () => {
    updateTodoList();
});
