import Foundation

/// Represents possible user authentication actions in the application
enum AuthAction: String {
  case signup = "sign-up"
  case login = "log-in"
  case resetPassword = "reset-password"
  case updateProfile = "update-profile"
}

/// A view that handles user authentication forms including signup, login, password reset, and profile updates.
///
/// Renders HTML forms with appropriate input fields and validation based on the specified authentication action.
///
/// - Parameters:
///    - action: The type of authentication form to display
///    - errorMessage: Optional error message to show above the form
///    - user: Optional `User` to pre-populate form fields
struct AuthView {
  let action: AuthAction
  let errorMessage: String
  let user: User?

  init(action: AuthAction, errorMessage: String = "", user: User? = nil) {
    self.action = action
    self.errorMessage = errorMessage
    self.user = user
  }

  public var signupInputs: String {
    """
    <div class="form-group">
        <label for="name">Name</label>
        <input 
            type="text" 
            id="name" 
            name="name"
            value="\(user?.name ?? "")"
            placeholder="Some Name"
            autocomplete="name"
            required
        >
    </div>
    <div class="form-group">
        <label for="email">Email</label>
        <input 
            type="email" 
            id="email" 
            name="email"
            value="\(user?.email ?? "")"
            placeholder="e.g. name@example.com"
            required
        >
    </div>
    <div class="form-group">
        <label for="password">Password</label>
        <input 
            type="password" 
            id="password" 
            name="password"
            placeholder="Choose a strong password"
            autocomplete="new-password"
            required
        >
    </div>
    <div class="form-group">
        <label for="password">Confirm Password</label>
        <input 
            type="password" 
            id="confirmPassword" 
            name="confirmPassword"
            placeholder="Re-enter your password"
            autocomplete="new-password"
            required
        >
    </div>
    """
  }

  private var loginInputs: String {
    """
    <div class="form-group">
        <label for="email">Email</label>
        <input 
            type="email" 
            id="email" 
            name="email"
            placeholder="Enter your email address"
            required
        >
    </div>
    <div class="form-group">
        <label for="password">Password</label>
        <input 
            type="password" 
            id="password" 
            name="password"
            placeholder="Enter your password"
            required
        >
        <a href="/reset-password">Forgotten password?</a>
    </div>
    """
  }

  private var resetPasswordInputs: String {
    """
    <div class="form-group">
        <label for="email">Email</label>
        <input 
            type="email" 
            id="email" 
            name="email"
            placeholder="Enter your email address"
            required
        >
    </div>
    """
  }

  // generate correct form inputs based on passed `AuthAction`
  private func generateInputs() -> String {
    switch action {
      case .signup, .updateProfile:
        return signupInputs
      case .login:
        return loginInputs
      case .resetPassword:
        return resetPasswordInputs
    }
  }

  func render() -> String {
    let titleText = action.rawValue.replacingOccurrences(of: "-", with: " ").capitalized
    let linkText = action == .login ? "No account yet?" : "Already have an account?"
    let linkHref = action == .login ? "/sign-up" : "/log-in"

    return """
      <form class="surface auth-form" action="\(action.rawValue)" method="post">
          \(!errorMessage.isEmpty ? "<span class='error'>\(errorMessage)</span>" : "")
          <h1>\(titleText)</h1>
          \(generateInputs())
          \(action == .updateProfile
              ? """
                <button id="settings-delete" class="destructive" style="margin-bottom: .5rem;" type="button">
                    Delete Account
                </button>
                <div class="btn-group">
                  <button id="settings-cancel">Cancel</button>
                  <button class="primary" type="submit">\(titleText)</button>
                </div>
                """
              : "<button class='primary' type='submit'>\(titleText)</button>"
            )
          \(action != .updateProfile && action != .resetPassword ? "<a href='\(linkHref)'>\(linkText)</a>" : "")
      </form>
      """
  }
}
