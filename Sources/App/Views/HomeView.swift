//
//  HomeView.swift
//  todos-auth-fluent
//
//  Created by Mac Long on 2024-11-04.
//

struct HomeView {
    func render() -> String {
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
              <a href="https://www.apple.com/uk/app-store/" class="btn primary">
                Get the App
              </a>
            </div>
          </div>
          <img src="images/hero.png" />
        </section>
        """
    }
}
