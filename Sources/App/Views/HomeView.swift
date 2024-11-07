struct HomeView {
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
        \(ActionButtons().render())
      </div>
      <img src="images/hero.svg" />
    </section>
    """
  }

  func featureList() -> String {
    """
    <section class="features">
        <div class="feature">
            <span class="icon">🎯</span>
            <h2>Reach Your Goals Faster</h2>
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
            <p>
                Sign up and get your life back on track! Stay organized, boost productivity, and achieve goals.
            </p>
            \(ActionButtons().render())
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
