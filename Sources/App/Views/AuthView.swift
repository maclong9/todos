import Foundation

enum AuthAction: String {
    case signup = "sign-up"
    case login = "log-in"
    case resetPassword = "reset-password"
    case updateProfile = "update-profile"
}

struct AuthView {
    let action: AuthAction
    let errorMessage: String
    
    init(action: AuthAction, errorMessage: String = "") {
        self.action = action
        self.errorMessage = errorMessage
    }
    
    public var signupInputs: String {
        """
        <div class="form-group">
            <label for="name">Name</label>
            <input 
                type="text" 
                id="name" 
                name="name" 
                placeholder="Enter your full name"
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
    
    // TODO: Add placeholders for user's current information to `.updateProfile` view.
    
    func render() -> String {
        let titleText = action.rawValue.replacingOccurrences(of: "-", with: " ").capitalized
        let linkText = action == .login ? "No account yet?" : "Already have an account?"
        let linkHref = action == .login ? "/sign-up" : "/log-in"
        
        return """
        <form class="surface auth-form" action="\(action.rawValue)" method="post">
            \(!errorMessage.isEmpty ? "<span class='error'>\(errorMessage)</span>" : "")
            <h1>\(titleText)</h1>
            \(generateInputs())
            \(action == .updateProfile ? """
                <button class="destructive" style="margin-bottom: .5rem;" type="button" onclick="settings.close(); deletion.showModal()">
                    Delete Account
                </button>
                <div class="btn-group">
                  <button onclick="settings.close()">Cancel</button>
                  <button class="primary" type="submit">\(titleText)</button>
                </div>
                """ :
                "<button class='primary' type='submit'>\(titleText)</button>"
            )
            \(action != .updateProfile && action != .resetPassword ? "<a href='\(linkHref)'>\(linkText)</a>" : "")
        </form>
        """
    }
}
