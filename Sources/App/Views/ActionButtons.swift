/// Call to Action Buttons for reusability across the site
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
