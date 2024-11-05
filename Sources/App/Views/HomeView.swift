//
//  HomeView.swift
//  todos-auth-fluent
//
//  Created by Mac Long on 2024-11-04.
//

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

  func scrollLock() -> String {
    """
    <section class="scroll-lock">
        <!-- TODO: Feature 1 -->
        <!-- TODO: Feature 2 -->
        <!-- TODO: Feature 3 -->
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
    \(scrollLock())
    \(callToAction())
    """
  }
}
