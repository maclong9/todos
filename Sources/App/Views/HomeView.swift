/// A view that renders the marketing landing page of the application.
///
/// Displays the main value proposition, feature highlights, and appropriate call-to-action
/// buttons based on user authentication state.
///
/// - Parameters:
///    - isLoggedIn: Whether a user is currently authenticated, affecting which CTAs are shown
struct HomeView {
  let isLoggedIn: Bool

  init(isLoggedIn: Bool = false) {
    self.isLoggedIn = isLoggedIn
  }

  func render() -> String {
    """
    <section class="grid hero">
      <div class="background"></div>
      <div class="text">
        <h1>
          Take Control of
          <span class="gradient-highlight">Your Life</span>
        </h1>
        <p>
          With this wonderful application, designed to make your life easier while
          staying out of the way. Take the first step in your new journey.
        </p>
        \(ActionButtons(isLoggedIn: isLoggedIn).render())
      </div>
      <img src="images/hero.svg" />
    </section>
    """
  }
}
