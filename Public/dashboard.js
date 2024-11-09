/** * @fileoverview Dashboard management system for Todo application
 * @description Handles todo creation, updates, deletion, and user management
 * @version 1.1.0
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
    constructor() {
        // Cache frequently used DOM elements
        this.main = document.querySelector(".dashboard main");
        this.todoContainer = document.querySelector(".list-container");
        this.form = document.querySelector(".todo-form");
        this.titleInput = document.querySelector("#title");

        // Track which todos are being edited
        this.dirtyTodos = new Set();

        this.initializeEventListeners();
    }

    initializeEventListeners() {
        this.form.addEventListener("submit", (e) => this.handleSubmit(e));
        
        document
            .querySelector(".dashboard")
            .addEventListener("click", (e) => this.handleDashboardClick(e));
        
        document
            .querySelector(".dashboard")
            .addEventListener("input", (e) => this.handleTodoInput(e));
    }

    async loadTodos() {
        try {
            const response = await fetch("/api/todos");
            const todos = await response.json();
            
            // Initial render
            this.todoContainer.innerHTML = todos.length
                ? this.createTodoList(todos)
                : "<p>You have nothing todo...</p>";
        } catch (error) {
            console.error("Failed to load todos:", error);
        }
    }

    createTodoList(todos) {
        return `
            <ul class="todo-list">
                ${todos.map(todo => this.createTodoElement(todo)).join("")}
            </ul>
        `;
    }

    createTodoElement(todo) {
        return `
            <li class="todo-item ${todo.completed ? "completed" : ""}" data-id="${todo.id}">
                <input type="checkbox" class="todo-checkbox" ${todo.completed ? "checked" : ""}>
                <input
                    type="text"
                    class="todo-title"
                    value="${this.escapeHtml(todo.title)}"
                    aria-label="Todo title"
                >
                <button class="todo-action unstyle" aria-label="save todo">
                    ${this.dirtyTodos.has(todo.id) ? "💾" : "🗑️"}
                </button>
            </li>
        `;
    }

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
            
            // Add the new todo to the list
            const newTodo = await response.json();
            
            // If "nothing todo" message is there, clear it
            if (this.todoContainer.querySelector("p")) {
                this.todoContainer.innerHTML = "<ul class='todo-list'></ul>";
            }
            
            // Create a temporary div to parse the HTML string
            const template = document.createElement('div');
            template.innerHTML = this.createTodoElement(newTodo);
            
            // Get the li element directly (firstElementChild will be the li)
            const todoElement = template.firstElementChild;
            this.todoContainer.querySelector(".todo-list").appendChild(todoElement);
            
            this.titleInput.value = "";
        } catch (error) {
            console.error("Failed to add todo:", error);
        }
    }

    async handleDashboardClick(event) {
        const target = event.target;
        const todoItem = target.closest(".todo-item");
        if (!todoItem) return;

        const todoId = todoItem.dataset.id;

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

    handleTodoInput(event) {
        const target = event.target;
        if (!target.matches(".todo-title")) return;

        const todoItem = target.closest(".todo-item");
        const todoId = todoItem.dataset.id;
        
        if (target.value.trim() !== target.defaultValue.trim()) {
            this.dirtyTodos.add(todoId);
        } else {
            this.dirtyTodos.delete(todoId);
        }
        
        const actionButton = todoItem.querySelector(".todo-action");
        actionButton.innerHTML = this.dirtyTodos.has(todoId) ? "💾" : "🗑️";
        actionButton.setAttribute("aria-label", this.dirtyTodos.has(todoId) ? "save todo" : "delete todo");
    }

    async saveTodoTitle(todoItem) {
        const titleInput = todoItem.querySelector(".todo-title");
        const newTitle = titleInput.value.trim();
        
        if (!newTitle) return;

        try {
            const response = await fetch(`/api/todos/${todoItem.dataset.id}`, {
                method: "PATCH",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ title: newTitle }),
            });

            if (!response.ok) throw new Error("Failed to update todo");
            
            titleInput.defaultValue = newTitle;
            this.dirtyTodos.delete(todoItem.dataset.id);
            
            const actionButton = todoItem.querySelector(".todo-action");
            actionButton.innerHTML = "🗑️";
            actionButton.setAttribute("aria-label", "delete todo");
        } catch (error) {
            console.error("Failed to update todo:", error);
        }
    }

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
            checkbox.checked = !checked;
        }
    }

    async deleteTodo(todoItem) {
        try {
            const response = await fetch(`/api/todos/${todoItem.dataset.id}`, {
                method: "DELETE",
                headers: { "Content-Type": "application/json" },
            });

            if (!response.ok) throw new Error("Failed to delete todo");
            
            // Remove the todo item from the DOM
            todoItem.remove();
            
            // If no todos left, show the "nothing todo" message
            if (!this.todoContainer.querySelector(".todo-item")) {
                this.todoContainer.innerHTML = "<p>You have nothing todo...</p>";
            }
        } catch (error) {
            console.error("Failed to delete todo:", error);
        }
    }

    escapeHtml(unsafe) {
        return unsafe
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    static async logout() {
        try {
            const response = await fetch("/api/users/logout", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
            });

					console.log(response);

            if (response.ok) {
                window.location.href = "/";
            }
        } catch (error) {
            console.error("Failed to logout:", error);
        }
    }
}

document.addEventListener("DOMContentLoaded", () => new TodoDashboard());
