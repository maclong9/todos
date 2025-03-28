/**
 * @fileoverview Dashboard management system for Todo application
 * @description Handles todo creation, updates, deletion, and user management
 * @license Apache-2.0
 */

/**
 * @typedef {Object} Todo
 * @property {string} id - Unique identifier for the todo
 * @property {string} title - The todo item's text content
 * @property {boolean} completed - Whether the todo is completed
 * @property {{id: string}} owner - The owner of the todo item
 */

/**
 * Class representing a Todo Dashboard application
 * @class TodoDashboardController
 * @description Manages the Todo application's UI and server interactions, including
 * todo creation, updates, and delete.
 */
class TodoDashboardController {
    constructor() {
        // Cache frequently used DOM elements for better performance
        this.dashboard = document.querySelector(".dashboard");
        this.main = this.dashboard.querySelector("main");
        this.todoContainer = this.main.querySelector(".list-container");
        this.form = this.main.querySelector(".todo-form");
        this.titleInput = this.main.querySelector("#title");

        // Dashboard Menu Items
        this.settingsOpen = this.dashboard.querySelector("#settings-open");
        this.settingsCancel = this.dashboard.querySelector("#settings-cancel");
        this.settingsDelete = this.dashboard.querySelector("#settings-delete");
        this.deletionCancel = this.dashboard.querySelector("#deletion-cancel");
        this.logoutButton = this.dashboard.querySelector("#logout-button");
        
      console.log(this.settingsOpen, this.logoutButton)
        // Dialogs
        this.settingsDialog = this.dashboard.querySelector("#settings");
        this.deletionDialog = this.dashboard.querySelector("#deletion");

        // Set to track todos that have unsaved changes
        this.dirtyTodos = new Set();

        // setup document event listeners
        this.initializeEventListeners();
        this.initializeDialogEventListeners();
        this.initializeKeyboardEventListeners();
    }

    /**
     * Initializes regular event listeners for the dashboard
     * @private
     * @returns {void}
     */
    initializeEventListeners() {
        // Handle new todo item submission
        this.form.addEventListener("submit", (e) => this.handleSubmit(e));

        // Handle clicks for todo items
        this.dashboard.addEventListener("click", (e) =>
            this.handleDashboardClick(e),
        );

        // Handle input changes for todo items
        this.dashboard.addEventListener("input", (e) =>
            this.handleTodoInput(e),
        );

        // Handle user logout
        this.logoutButton.addEventListener("click", () =>
            TodoDashboardController.logout(),
        );
    }

    /**
     * Initializes event listeners for dialog interactions
     * @private
     * @returns {void}
     */
    initializeDialogEventListeners() {
        // Settings dialog open/close
        this.settingsOpen.addEventListener("click", () => settings.showModal());
        this.settingsCancel.addEventListener("click", () => settings.close());

        // Open delete account menu
        this.settingsDelete.addEventListener("click", () => {
            settings.close();
            deletion.showModal();
        });

        // Cancel delete account menu
        this.deletionCancel.addEventListener("click", () => deletion.close());
    }
    
    /**
     * Initializes keyboard event listeners for the dashboard
     * @private
     * @returns {void}
     */
    initializeKeyboardEventListeners() {
        this.dashboard.addEventListener("keydown", async (e) => {
            // Check if the pressed key is Enter
            if (e.key === "Enter") {
                const target = e.target;

                // Check if we're in a todo title input that has unsaved changes
                if (target.matches(".todo-title")) {
                    const todoItem = target.closest(".todo-item");
                    const todoId = todoItem.dataset.id;

                    // Only save if the todo is dirty (has unsaved changes)
                    if (this.dirtyTodos.has(todoId)) {
                        e.preventDefault(); // Prevent default enter behavior
                        await this.saveTodoTitle(todoItem);
                        target.blur(); // Remove focus after saving
                    }
                }
            }
        });
    }

    /**
     * Creates an HTML string representation of a todo item
     * @param {Todo} todo - The todo object to create an element for
     * @returns {string} HTML string representing the todo item
     */
    createTodoElement(todo) {
        return `
        <li 
            class="todo-item ${todo.completed ? "completed" : ""}" 
            data-id="${todo.id}"
        >
            <input 
                type="checkbox" 
                class="todo-checkbox" 
                ${todo.completed ? "checked" : ""}
            >
            <input
                type="text"
                class="todo-title"
                value="${this.escapeHtml(todo.title)}"
                aria-label="Todo title"
            >
            <button 
                class="todo-action unstyle" 
                aria-label="save todo"
            >
                ${this.dirtyTodos.has(todo.id) ? "💾" : "🗑️"}
            </button>
        </li>
        `;
    }

    /**
     * Handles form submission for creating new todos
     * @async
     * @param {Event} event - The form submission event
     * @returns {Promise<void>}
     * @throws {Error} When the API request fails
     */
    async handleSubmit(event) {
        event.preventDefault();
        const title = this.titleInput.value.trim();
        if (!title) return;

        try {
            // attempts to create new todo on server and store if successful
            const response = await fetch("/api/todos", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ title }),
            });
            if (!response.ok) throw new Error("Failed to add todo");
            const newTodo = await response.json();

            // Clear "nothing todo" message if present
            if (this.todoContainer.querySelector("p")) {
                this.todoContainer.innerHTML = "<ul class='todo-list'></ul>";
            }

            // Append the new todo item
            const todoElement = document
                .createRange()
                .createContextualFragment(
                    this.createTodoElement(newTodo),
                ).firstElementChild;
            this.todoContainer
                .querySelector(".todo-list")
                .appendChild(todoElement);

            // reset new todo form input
            this.titleInput.value = "";
        } catch (error) {
            console.error("Failed to add todo:", error);
        }
    }

    /**
     * Handles click events within the dashboard
     * @async
     * @param {MouseEvent} event - The click event
     * @returns {Promise<void>}
     */
    async handleDashboardClick(event) {
        // check if click was inside a todo item
        const target = event.target;
        const todoItem = target.closest(".todo-item");
        if (!todoItem) return;

        // store clicked todos id
        const todoId = todoItem.dataset.id;

        // check if click is on `checkbox` or `todo-action` and perform relevant action
        if (target.matches(".todo-checkbox")) {
            await this.toggleTodoStatus(todoItem, target);
        } else if (target.matches(".todo-action")) {
            if (this.dirtyTodos.has(todoId)) {
                await this.saveTodoTitle(todoItem);
            } else {
                await this.deleteTodo(todoItem);
            }
        }
    }

    /**
     * Handles input events for todo titles
     * @param {InputEvent} event - The input event
     * @returns {void}
     */
    handleTodoInput(event) {
        // checks if todo item input has been edited and stores `todo.id`
        const target = event.target;
        if (!target.matches(".todo-title")) return;
        const todoItem = target.closest(".todo-item");
        const todoId = todoItem.dataset.id;

        // Track whether the todo has unsaved changes
        if (target.value.trim() !== target.defaultValue.trim()) {
            this.dirtyTodos.add(todoId);
        } else {
            this.dirtyTodos.delete(todoId);
        }

        // Update the action button appearance
        const actionButton = todoItem.querySelector(".todo-action");
        actionButton.innerHTML = this.dirtyTodos.has(todoId) ? "💾" : "🗑️";
        actionButton.setAttribute(
            "aria-label",
            this.dirtyTodos.has(todoId) ? "save todo" : "delete todo",
        );
    }

    /**
     * Saves changes to a todo's title
     * @async
     * @param {HTMLElement} todoItem - The todo item element
     * @returns {Promise<void>}
     * @throws {Error} When the API request fails
     */
    async saveTodoTitle(todoItem) {
        const titleInput = todoItem.querySelector(".todo-title");
        const newTitle = titleInput.value.trim();

        if (!newTitle) return;

        try {
            // attempts to update relevant todo item on the server
            const response = await fetch(`/api/todos/${todoItem.dataset.id}`, {
                method: "PATCH",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ title: newTitle }),
            });
            if (!response.ok) throw new Error("Failed to update todo");

            // resets the items input and removes `dirty` state
            titleInput.defaultValue = newTitle;
            this.dirtyTodos.delete(todoItem.dataset.id);

            // resets action button to `delete` instead of `save`
            const actionButton = todoItem.querySelector(".todo-action");
            actionButton.innerHTML = "🗑️";
            actionButton.setAttribute("aria-label", "delete todo");
        } catch (error) {
            console.error("Failed to update todo:", error);
        }
    }

    /**
     * Toggles the completed status of a todo
     * @async
     * @param {HTMLElement} todoItem - The todo item element
     * @param {HTMLInputElement} checkbox - The checkbox element
     * @returns {Promise<void>}
     * @throws {Error} When the API request fails
     */
    async toggleTodoStatus(todoItem, checkbox) {
        const checked = checkbox.checked;
        try {
            // attempt to toggle `todo.completed` on server
            const response = await fetch(`/api/todos/${todoItem.dataset.id}`, {
                method: "PATCH",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ completed: checked }),
            });
            if (!response.ok) throw new Error("Failed to update todo");

            // updates UI to reflect completed state
            todoItem.classList.toggle("completed", checked);
            checkbox.setAttribute("checked", checked);
            checkbox.ariaLabel = `Mark ${todoItem.title} as ${
                checked ? "incomplete" : "complete"
            }`;
        } catch (error) {
            console.error("Failed to update todo:", error);
            checkbox.checked = !checked;
        }
    }

    /**
     * Deletes a todo item
     * @async
     * @param {HTMLElement} todoItem - The todo item element to delete
     * @returns {Promise<void>}
     * @throws {Error} When the API request fails
     */
    async deleteTodo(todoItem) {
        try {
            // attempts to remove todo item from server
            const response = await fetch(`/api/todos/${todoItem.dataset.id}`, {
                method: "DELETE",
                headers: { "Content-Type": "application/json" },
            });
            if (!response.ok) throw new Error("Failed to delete todo");

            // Remove the todo item from the DOM
            todoItem.remove();

            // Show "nothing todo" message if no todos remain
            if (!this.todoContainer.querySelector(".todo-item")) {
                this.todoContainer.innerHTML =
                    "<p>You have nothing todo...</p>";
            }
        } catch (error) {
            console.error("Failed to delete todo:", error);
        }
    }

    /**
     * Escapes HTML special characters to prevent XSS attacks
     * @param {string} unsafe - The unsafe string to escape
     * @returns {string} The escaped string
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
     * Logs out the current user
     * @static
     * @async
     * @returns {Promise<void>}
     * @throws {Error} When the logout request fails
     */
    static async logout() {
        try {
            // attempts to logout the user by deleting their session
            const response = await fetch("/api/users/logout", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
            });

            // redirect to home page if successful
            if (response.ok) {
                window.location.href = "/";
            }
        } catch (error) {
            console.error("Failed to logout:", error);
        }
    }
}

// Initialize the dashboard when the DOM is fully loaded
document.addEventListener(
    "DOMContentLoaded",
    () => new TodoDashboardController(),
);
