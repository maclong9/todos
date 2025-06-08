import WebUI

struct TodoApp: Website {
  var metadata: Metadata {
    Metadata(
      site: "Todo App",
      description:
        "A simple, elegant, and powerful way to manage your tasks",
      author: "Todo App Team",
      keywords: [
        "todo", "tasks", "productivity", "swift", "hummingbird",
      ],
      themeColor: .init("#101010"),
    )
  }

  // Vesper color scheme
  static let colors = [
    "primary": "#99FFE4",  // peppermint green accent
    "primary-hover": "#7AFFD4",  // darker peppermint
    "secondary": "#FFE4CC",  // light beige
    "secondary-hover": "#FFD4B3",  // darker beige
    "accent": "#A0A0A0",  // gray accent
    "background": "#101010",  // dark background
    "foreground": "#FFFFFF",  // white text
    "muted": "#737373",  // muted gray
    "muted-foreground": "#A3A3A3",  // lighter muted
    "border": "#2A2A2A",  // dark border
    "input": "#1C1C1C",  // dark input background
    "ring": "#99FFE4",  // focus ring color
    "error": "#FF4D4D",  // error red
  ]

  var routes: [any Document] {}

  // Common styles
  static let commonStyles = """
        :root {
            /* Colors */
            --primary: \(colors["primary"]!);
            --primary-hover: \(colors["primary-hover"]!);
            --secondary: \(colors["secondary"]!);
            --secondary-hover: \(colors["secondary-hover"]!);
            --accent: \(colors["accent"]!);
            --background: \(colors["background"]!);
            --foreground: \(colors["foreground"]!);
            --muted: \(colors["muted"]!);
            --muted-foreground: \(colors["muted-foreground"]!);
            --border: \(colors["border"]!);
            --input: \(colors["input"]!);
            --ring: \(colors["ring"]!);
            --error: \(colors["error"]!);

            /* Typography */
            --font-sans: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            --font-size-sm: 0.875rem;
            --font-size-base: 1rem;
            --font-size-lg: 1.125rem;
            --font-size-xl: 1.5rem;
            --font-size-2xl: 1.875rem;
            --font-size-3xl: 3rem;

            /* Spacing */
            --spacing-1: 0.25rem;
            --spacing-2: 0.5rem;
            --spacing-3: 0.75rem;
            --spacing-4: 1rem;
            --spacing-6: 1.5rem;
            --spacing-8: 2rem;

            /* Border Radius */
            --radius-sm: 0.375rem;
            --radius-md: 0.5rem;

            /* Shadows */
            --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
            --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.2), 0 2px 4px -2px rgb(0 0 0 / 0.2);
            --shadow-lg: 0 8px 12px -1px rgb(0 0 0 / 0.2), 0 4px 6px -2px rgb(0 0 0 / 0.2);

            /* Transitions */
            --transition-all: all 0.2s ease;
        }

        /* Base Styles */
        body {
            font-family: var(--font-sans);
            font-weight: 400;
            background-color: var(--background);
            color: var(--foreground);
            margin: 0;
            min-height: 100dvh;
            display: flex;
            flex-direction: column;
            line-height: 1.5;
        }

        /* Typography */
        h1, h2, h3, h4, h5, h6, label {
            font-family: var(--font-sans);
            font-weight: 600;
            color: var(--foreground);
            text-transform: none;
        }

        h1 {
            font-size: var(--font-size-3xl);
        }

        .description {
            font-size: var(--font-size-lg);
            line-height: 1.75;
            margin: var(--spacing-2) 0;
            color: var(--muted-foreground);
        }

        /* Header */
        header {
            padding: var(--spacing-4) var(--spacing-8);
            background: var(--background);
            border-bottom: 1px solid var(--border);
            margin-bottom: var(--spacing-1);

            .content {
                display: flex;
                justify-content: space-between;
                align-items: center;
                max-width: 1200px;
                margin: 0 auto;
            }

            .title {
                font-size: var(--font-size-2xl);
                text-decoration: none;
                font-weight: 600;
            }

            nav {
                display: flex;
                align-items: center;
                gap: var(--spacing-3);
            }
        }

        /* Layout */
        main {
            width: 100%;
            max-width: 95vw;
            margin: 0 auto;
            background: var(--background);
            border: 1px solid var(--border);
            box-shadow: var(--shadow-md);
            border-radius: var(--radius-md);
            overflow: hidden;
            padding: var(--spacing-4) var(--spacing-1);
            margin: var(--spacing-8) auto;
            flex-grow: 1;

            @media(min-width: 768px) {
                padding: var(--spacing-8);
                max-width: 1200px;
            }
        }

        .center {
            text-align: center;
            
            .description {
                margin: 0 auto var(--spacing-4);
                max-width: 360px;
                line-height: 1.2
            }
        }

        /* Buttons */
        button, .btn {
            padding: var(--spacing-2) var(--spacing-2);
            border: 1px solid var(--border);
            font-size: var(--font-size-sm);
            font-family: var(--font-sans);
            font-weight: 600;
            cursor: pointer;
            border-radius: var(--radius-md);
            transition: var(--transition-all);
            text-transform: none;
            background: var(--primary);
            color: var(--background);

            &:hover {
                background: var(--primary-hover);
                transform: translateY(-1px);
                box-shadow: var(--shadow-md);
            }

            &.secondary {
                background: var(--secondary);
                color: var(--background);

                &:hover {
                    background: var(--secondary-hover);
                }
            }
        }

        /* Forms */
        input {
            width: 100%;
            padding: var(--spacing-3) var(--spacing-4);
            margin-bottom: var(--spacing-4);
            border: 1px solid var(--border);
            font-size: var(--font-size-sm);
            background: var(--background);
            color: var(--foreground);
            border-radius: var(--radius-md);
            outline: none;
            transition: var(--transition-all);
            font-family: var(--font-sans);

            &:focus {
                border-color: var(--ring);
                box-shadow: 0 0 0 2px var(--ring);
            }
        }

        .form-container {
            transition: var(--transition-all);
            background: var(--input);
            padding: var(--spacing-8);
            box-shadow: var(--shadow-md);
            margin: 0 auto;
            border: 1px solid var(--border);

            &:hover {
                box-shadow: var(--shadow-lg);
            }

            button, .btn {
                width: 100%;
            }
        }

        /* Messages */
        .error-message, .success-message {
            padding: var(--spacing-4);
            border-radius: var(--radius-md);
            margin-bottom: var(--spacing-6) !important;
            text-align: center;
            font-weight: 500;
            font-family: var(--font-sans);
            font-size: var(--font-size-sm);
            max-width: 400px;
            margin: 0 auto;
        }

        .error-message {
            background: var(--error);
            color: var(--foreground);
        }

        .success-message {
            background: var(--primary);
            color: var(--background);
        }

        /* Footer */
        footer {
            text-align: center;
            padding: var(--spacing-8);
            font-size: var(--font-size-sm);
            color: var(--muted);
            border-top: 1px solid var(--border);

            a {
                color: var(--primary);
                text-decoration: none;
                transition: var(--transition-all);

                &:hover {
                    color: var(--primary-hover);
                    text-decoration: underline;
                }
            }
        }
    """

  var scripts: [Script]? {
    [
      Script(attribute: .defer) {
        """
        // Fetch and display todos
        async function loadTodos() {
            const response = await fetch('/api/todos');
            const todos = await response.json();
            const todoList = document.getElementById('todo-list');
            
            todoList.innerHTML = todos.map(todo => `
                <div class="flex items-center gap-2 p-4 bg-white rounded-lg shadow-sm ${todo.isCompleted ? 'bg-green-50' : ''}">
                    <input 
                        type="checkbox" 
                        class="w-5 h-5 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                        ${todo.isCompleted ? 'checked' : ''}
                        onchange="updateTodo('${todo.id}', this.checked)"
                    >
                    <span class="flex-grow ${todo.isCompleted ? 'line-through text-gray-500' : ''}">
                        ${todo.title}
                    </span>
                    <button 
                        class="text-red-600 hover:text-red-800" 
                        onclick="deleteTodo('${todo.id}')"
                    >
                        ×
                    </button>
                </div>
            `).join('');
        }

        // Add new todo
        document.querySelector('form[action="/api/todos"]').addEventListener('submit', async (e) => {
            e.preventDefault();
            const title = e.target.title.value;
            
            await fetch('/api/todos', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ title })
            });
            
            e.target.reset();
            loadTodos();
        });

        // Update todo
        async function updateTodo(id, isCompleted) {
            await fetch(`/api/todos/${id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ isCompleted })
            });
            
            loadTodos();
        }

        // Delete todo
        async function deleteTodo(id) {
            await fetch(`/api/todos/${id}`, { 
                method: 'DELETE' 
            });
            
            loadTodos();
        }

        // Load todos on page load
        loadTodos();
        """
      }
    ]
  }
}
