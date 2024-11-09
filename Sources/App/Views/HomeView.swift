/// marketing page view
struct HomeView {
  let isLoggedIn: Bool

  init(isLoggedIn: Bool = false) {
    self.isLoggedIn = isLoggedIn
  }

  func heroSection() -> String {
    """
    <section class="grid hero">
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

  func featureList() -> String {
    """
    <h2 class="text-xl">Features</h2>
    <section class="grid gap three">
        <div class="feature">
            <span class="icon">🎯</span>
            <h2>Reach Goals Faster</h2>
            <p>With quick, simple and easy task management.</p>
        </div>
        <div class="feature">
            <span class="icon">📲</span>
            <h2>Check Off On the Go</h2>
            <p>Check off tasks as you rush about your busy day.</p>
        </div>  
        <div class="feature">
            <span class="icon">😎</span>
            <h2>Chill Out and Relax</h2>
            <p>With your life back on track, enjoy more time relaxing.</p>
        </div>
    </section>
    """
  }

  func callToAction() -> String {
    """
    <section>
        <div class="cta">
            <h2 class="gradient-highlight">Get Started Now</h1>
            <p>\(isLoggedIn 
                  ? "Thanks for signing up, keep track of your day to day goals in your dashboard or the app"
                  : "Sign up and get your life back on track! Stay organized, boost productivity, and achieve goals.")
            </p>
            \(ActionButtons(isLoggedIn: isLoggedIn).render())
        </div>
    </section>
    """
  }

  func render() -> String {
    """
    \(heroSection())
    \(featureList())
    \(callToAction())
    """
  }
}
