import WebUI

struct HomeView: Document {
  let errorMessage: String?
  let email: String?
  let successMessage: String?

  init(
    errorMessage: String? = nil, email: String? = nil,
    successMessage: String? = nil
  ) {
    self.errorMessage = errorMessage
    self.email = email
    self.successMessage = successMessage
  }

  var path: String { "index" }
  var metadata: Metadata {
    Metadata(
      from: TodoApp().metadata,
      title: "Welcome",
      description:
        "A simple, elegant, and powerful way to manage your tasks",
      themeColor: TodoApp().metadata.themeColor
    )
  }

  var scripts: [Script]? {
    [
      Script(attribute: .defer) {
        """
        // Tab switching functionality
        function switchTab(tabName) {
            // Hide all forms
            document.querySelectorAll('.auth-form').forEach(form => {
                form.style.display = 'none';
            });
            
            // Show selected form
            document.getElementById(tabName + '-form').style.display = 'block';
            
            // Update active tab
            document.querySelectorAll('.auth-tab').forEach(tab => {
                tab.classList.remove('active');
            });
            document.getElementById(tabName + '-tab').classList.add('active');
        }

        // Initialize with signup form
        switchTab('signup');
        """
      }
    ]
  }

  var head: String? {
    """
    <style>
    \(TodoApp.commonStyles)
    /* Home Page Specific Styles */
    .auth-container {
        animation: fadeIn 0.3s ease-in-out;
        max-width: 420px;
        min-height: 466px;
        margin: 0 auto;
        border-radius: var(--radius-lg) !important;
    }

    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(10px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .auth-tabs {
        display: flex;
        background: var(--input);
        border: 1px solid var(--border);
        border-radius: var(--radius-md) var(--radius-md) 0 0;
        padding: var(--spacing-1);
        margin-bottom: 0;
        gap: var(--spacing-2);
    }

    .auth-tab {
        flex: 1;
        position: relative;
        padding: var(--spacing-3) var(--spacing-4);
        font-family: var(--font-sans);
        font-weight: 600;
        font-size: var(--font-size-sm);
        color: var(--muted);
        background: transparent;
        border: none;
        cursor: pointer;
        transition: var(--transition-all);
        border-radius: var(--radius-sm);

        &:hover {
            color: var(--foreground);
        }

        &.active {
            background: var(--primary);
            color: var(--background);
        }
    }

    .auth-form {
        animation: slideIn 0.3s ease-in-out;
        display: none;
        padding: var(--spacing-6);
        background: var(--input);
        border: 1px solid var(--border);
        border-top: none;
    }

    @keyframes slideIn {
        from { opacity: 0; transform: translateX(-10px); }
        to { opacity: 1; transform: translateX(0); }
    }

    .form-title {
        color: var(--foreground);
        margin-bottom: var(--spacing-6);
        text-align: center;
        font-family: var(--font-sans);
        font-weight: 600;
        font-size: var(--font-size-xl);
    }

    .reset-link, .back-link {
        transition: var(--transition-all);
        border-radius: var(--radius-md);
        background: transparent;
        color: var(--muted);
        padding: var(--spacing-2) 0;
        border: none;
        cursor: pointer;
        display: block;
        text-align: center;
        margin-top: var(--spacing-4);
        font-family: var(--font-sans);
        font-weight: 500;
        font-size: var(--font-size-sm);
        text-transform: none;

        &:hover {
            color: var(--foreground);
        }
    }

    .center {
        text-align: center;
        margin: 0 auto;

        h1 {
            font-size: var(--font-size-2xl);
        }
    }
    </style>
    """
  }

  var body: some HTML {
    LayoutView {
      Stack(classes: ["center"]) {
        Heading(.largeTitle) { "Todo App" }
        Text(classes: ["description"]) {
          "Welcome to the Todo App! A simple, elegant, and powerful way to manage your tasks."
        }

        // Show error message if present
        if let errorMessage = errorMessage {
          Stack(classes: ["error-message"]) {
            Text { errorMessage }
          }
        }

        // Show success message if present
        if let successMessage = successMessage {
          Stack(classes: ["success-message"]) {
            Text { successMessage }
          }
        }

        Stack(classes: ["auth-container", "form-container"]) {
          // Auth tabs
          Stack(classes: ["auth-tabs"]) {
            Button(
              onClick: "switchTab('signup')", id: "signup-tab",
              classes: ["auth-tab"]
            ) {
              "Sign Up"
            }
            Button(
              onClick: "switchTab('login')", id: "login-tab",
              classes: ["auth-tab"]
            ) {
              "Log In"
            }
          }

          // Sign Up Form
          Stack(
            id: "signup-form",
            classes: ["auth-form", "form-container"]
          ) {
            Heading(.title, classes: ["form-title"]) { "Sign Up" }
            Form(action: "/api/auth/signup", method: .post) {
              Input(
                name: "name", type: .text, placeholder: "Name",
                required: true)
              Input(
                name: "email", type: .email, value: email,
                placeholder: "Email", required: true)
              Input(
                name: "password", type: .password,
                placeholder: "Password", required: true)
              Button(type: .submit) { "Sign Up" }
            }
          }

          // Login Form
          Stack(
            id: "login-form",
            classes: ["auth-form", "form-container"]
          ) {
            Heading(.title, classes: ["form-title"]) { "Login" }
            Form(action: "/api/auth/login", method: .post) {
              Input(
                name: "email", type: .email, value: email,
                placeholder: "Email", required: true)
              Input(
                name: "password", type: .password,
                placeholder: "Password", required: true)
              Button(type: .submit) { "Log In" }
              Button(
                onClick: "switchTab('reset')",
                classes: ["reset-link"]
              ) {
                "Forgot your password?"
              }
            }
          }

          // Reset Password Form
          Stack(
            id: "reset-form",
            classes: ["auth-form", "form-container"]
          ) {
            Heading(.title, classes: ["form-title"]) {
              "Reset Password"
            }
            Form(action: "/api/auth/reset-password", method: .post) {
              Input(
                name: "email", type: .email, value: email,
                placeholder: "Email", required: true)
              Button(type: .submit) { "Reset Password" }
              Button(
                onClick: "switchTab('login')",
                classes: ["back-link"]
              ) { "Back to Login" }
            }
          }
        }
      }
    }
  }
}
