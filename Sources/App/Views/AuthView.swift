struct AuthView {
    let isLogin: Bool
    let action: String
    let errorMessage: String
    
    init(isLogin: Bool = false, errorMessage: String = "") {
        self.isLogin = isLogin
        self.action = isLogin ? "/login" : "/signup"
        self.errorMessage = errorMessage
    }
    
    let loginInputs: String = """
        <div class="form-group">
            <label for="email">Email</label>
            <input 
                type="email" 
                id="email" 
                name="email"
                required
            >
        </div>
        <div class="form-group">
            <label for="password">Password</label>
            <input 
                type="password" 
                id="password" 
                name="password"
                required
            >
        </div>
    """
    
    let signupInputs: String = """
        <div class="form-group">
            <label for="name">Name</label>
            <input 
                type="text" 
                id="name" 
                name="name" 
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
                required
            >
        </div>
        <div class="form-group">
            <label for="password">Password</label>
            <input 
                type="password" 
                id="password" 
                name="password"
                autocomplete="new-password"
                required
            >
        </div>
        <div class="form-group">
            <label for="password">Confirm Password</label>
            <input 
                type="password" 
                id="password" 
                name="password"
                autocomplete="new-password"
                required
            >
        </div>
    """
    
    func render() -> String {
        """
        <form class="auth-form" action="\(action)" method="post">
            \(!errorMessage.isEmpty ? "<span class='error'>\(errorMessage)</span>" : "")
            <h1>\(isLogin ? "Log In" : "Sign Up")</h1>
            \(isLogin ? loginInputs : signupInputs)
            <button class="primary" type="submit">\(isLogin ? "Log In" : "Sign Up")</button>
            \(isLogin ? "<a href='/signup'>No account yet?</a>" : "<a href='/login'>Already have an account?</a>")
        </form>
        """
    }
}
