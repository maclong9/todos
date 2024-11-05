struct HomeView {
  let appStoreUrl: String

  func heroSection() -> String {
    """
    <section class="container">
      <div class="left">
        <h1>
          Take Control of
          <span class="gradient-highlight">Your Life</span>
        </h1>
        <p>
          With this wonderful application, designed to make your life easier while
          staying out of the way. Take the first step in your new journey.
        </p>
        <div class="btn-group">
          <a
            href="https://github.com/maclong9/todos"
            class="btn"
            rel="noopener noreferrer"
            >View Source</a
          >
          <a href="\(appStoreUrl)" class="btn primary">
            Get the App
          </a>
        </div>
      </div>
      <img src="images/hero.png" />
    </section>
    """
  }

  func featureList() -> String {
    """
    <section class="features">
        <div class="feature">
            <span class="icon">🎯</span>
            <h2>Reach Your Goals Faster</h2>
            <p>With quick and easy task management.</p>
        </div>
        <div class="feature">
            <span class="icon">📲</span>
            <h2>On the Go</h2>
            <p>Check off tasks as you rush about.</p>
        </div>  
        <div class="feature">
            <span class="icon">😎</span>
            <h2>Chill Out and Relax</h2>
            <p>Life back on track, enjoy more time relaxing.</p>
        </div>
    </section>
    """
  }

  func callToAction() -> String {
    """
    <section class="cta">
        <h2 class="gradient-highlight">Get Started Now</h1>
        <p>Sign up and get your life back on track with Swift Todos!</p>
        <div class="btn-group">
            <a href="/signup" class="btn">Sign Up</a>
            <a href="\(appStoreUrl)" class="btn primary">Get the App</a>
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
