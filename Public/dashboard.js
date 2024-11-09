/**
 * @fileoverview Dashboard management system for Todo application
 * @description Handles todo creation, updates, deletion, and user management
 * @author [Your Name]
 * @version 1.0.0
 *
 * @typedef {Object} Todo
 * @property {string} id - Unique identifier for the todo
 * @property {string} title - The todo item's text content
 * @property {boolean} completed - Whether the todo is completed
 * @property {{id: string}} owner - The owner of the todo item
 */

/**
 * Class representing a Todo Dashboard application
 * @class
 * @description Manages the Todo application's UI and server interactions
 */
class TodoDashboard {
    /**
     * Create a new TodoDashboard instance
     * Initializes DOM references and sets up event listeners
     * @constructor
     */
    constructor() {
        // Cache frequently used DOM elements
        this.main = document.querySelector(".dashboard main");
        this.form = document.querySelector(".todo-form");
        this.titleInput = document.getElementById("title");

        this.initializeEventListeners();
        this.loadTodos();
    }

    /**
     * Initialize event listeners for the dashboard
     * @private
     * @returns {void}
     */
    initializeEventListeners() {
        // Handle form submissions for new todos
        this.form.addEventListener("submit", (e) => this.handleSubmit(e));

        // Use event delegation for todo item interactions
        document
            .querySelector(".dashboard")
            .addEventListener("click", (e) => this.handleDashboardClick(e));
    }

    /**
     * Load todos from the server and render them
     * @async
     * @returns {Promise<void>}
     */
    async loadTodos() {
        try {
            const response = await fetch("/api/todos");
            const todos = await response.json();
            this.renderTodos(todos);
        } catch (error) {
            console.error("Failed to load todos:", error);
        }
    }

    /**
     * Render the todo list or empty state message
     * @param {Todo[]} todos - Array of todo items to render
     * @returns {void}
     */
    renderTodos(todos) {
        // Show empty state message if no todos, otherwise render todo list
        this.main.querySelector(".todo-list").innerHTML = todos.length
            ? this.createTodoList(todos)
            : "<p>You have nothing todo...</p>";
    }

    /**
     * Generate HTML for the todo list
     * @param {Todo[]} todos - Array of todo items
     * @returns {string} HTML string representing the todo list
     * @private
     */
    createTodoList(todos) {
        return `
            <ul class="todo-list">
                ${todos
                    .map(
                        (todo) => `
                            <li class="todo-item ${todo.completed ? "completed" : ""}" data-id="${todo.id}">
                                <input type="checkbox" class="todo-checkbox" ${todo.completed ? "checked" : ""}>
                                <span class="todo-title">${this.escapeHtml(todo.title)}</span>
                                <button class="delete-todo unstyle" aria-label="delete todo">🗑️</button>
                            </li>
                        `,
                    )
                    .join("")}
            </ul>
        `;
    }

    /**
     * Handle form submission for new todos
     * @param {Event} event - The form submission event
     * @async
     * @returns {Promise<void>}
     * @private
     */
    async handleSubmit(event) {
        event.preventDefault();
        const title = this.titleInput.value.trim();
        if (!title) return;

        try {
            const response = await fetch("/api/todos", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ title }),
            });

            if (!response.ok) throw new Error("Failed to add todo");
            this.titleInput.value = ""; // Clear input on success
            await this.loadTodos(); // Refresh the todo list
        } catch (error) {
            console.error("Failed to add todo:", error);
        }
    }

    /**
     * Handle click events within the dashboard
     * @param {Event} event - The click event
     * @async
     * @returns {Promise<void>}
     * @private
     */
    async handleDashboardClick(event) {
        const target = event.target;
        const todoItem = target.closest(".todo-item");
        if (!todoItem) return;

        const todoId = todoItem.dataset.id;

        // Delegate to appropriate handler based on clicked element
        if (target.matches(".todo-checkbox")) {
            await this.toggleTodoStatus(todoItem, target);
        } else if (target.matches(".delete-todo")) {
            await this.deleteTodo(todoId);
        }
    }

    /**
     * Toggle the completed status of a todo item
     * @param {HTMLElement} todoItem - The todo item element
     * @param {HTMLInputElement} checkbox - The checkbox element
     * @async
     * @returns {Promise<void>}
     * @private
     */
    async toggleTodoStatus(todoItem, checkbox) {
        const checked = checkbox.checked;
        try {
            const response = await fetch(`/api/todos/${todoItem.dataset.id}`, {
                method: "PATCH",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ completed: checked }),
            });

            if (!response.ok) throw new Error("Failed to update todo");
            todoItem.classList.toggle("completed", checked);
        } catch (error) {
            console.error("Failed to update todo:", error);
            checkbox.checked = !checked; // Revert checkbox state on error
        }
    }

    /**
     * Delete a todo item
     * @param {string} todoId - ID of the todo to delete
     * @async
     * @returns {Promise<void>}
     * @private
     */
    async deleteTodo(todoId) {
        try {
            const response = await fetch(`/api/todos/${todoId}`, {
                method: "DELETE",
                headers: { "Content-Type": "application/json" },
            });

            if (!response.ok) throw new Error("Failed to delete todo");
            await this.loadTodos(); // Refresh the todo list
        } catch (error) {
            console.error("Failed to delete todo:", error);
        }
    }

    /**
     * Escape HTML special characters to prevent XSS attacks
     * @param {string} unsafe - String containing potentially unsafe HTML
     * @returns {string} Escaped safe HTML string
     * @private
     */
    escapeHtml(unsafe) {
        return unsafe
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    /**
     * Log out the current user
     * @static
     * @async
     * @returns {Promise<void>}
     */
    static async logout() {
        try {
            const response = await fetch("/api/users/logout", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
            });

            if (response.ok) {
                window.location.href = "/";
            }
        } catch (error) {
            console.error("Failed to logout:", error);
        }
    }
}

// Initialize the dashboard when the DOM is fully loaded
document.addEventListener("DOMContentLoaded", () => new TodoDashboard());
