/// A collection of reusable call-to-action buttons for site-wide use.
///
/// Renders context-appropriate buttons based on navigation placement and user authentication state.
///
/// - Parameters:
///    - isNavigation: Whether the buttons appear in the header navigation
///    - isLoggedIn: Whether a user is currently authenticated. When true, displays a Dashboard button instead of Get Started
struct ActionButtons {
  let isNavigation: Bool
  let isLoggedIn: Bool

  init(isNavigation: Bool = false, isLoggedIn: Bool = false) {
    self.isNavigation = isNavigation
    self.isLoggedIn = isLoggedIn
  }

  func render() -> String {
    """
    <div class="btn-group \(isNavigation ? "col" : "")">
        \(isLoggedIn ? "<a class='btn' href='/dashboard'>Dashboard</a>"
                     : "<a class='btn' href='/sign-up'>Get Started</a>")
          <a class="btn primary" href="https://apple.com/uk/app-store">
            Get the App
          </a>
        </div>
    """
  }
}
