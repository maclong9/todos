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

    func heroSection() -> String {
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

    // TODO: Make into a sticky scrollable animation like on Stripe's homepage
    func featureList() -> String {
        """
        <section class="grid sticky">
          <div class="left">
            <div class="text">
              <span class="subtitle gradient-highlight">Be Productive</span>
              <h2>Reach Goals Faster</h2>
              <p>
                With quick, simple and easy task management, you can streamline your
                to-do list, prioritize important tasks, and stay focused on achieving
                your goals more efficiently. Say goodbye to the clutter and confusion of
                a disorganized workflow.
              </p>
            </div>

            <div class="text">
              <span class="subtitle gradient-highlight">Mobile Application</span>
              <h2>Check Off On the Go</h2>
              <p>
                Check off tasks as you rush about your busy day, ensuring nothing falls
                through the cracks. Stay on top of your responsibilities with the
                convenience of mobile access, allowing you to manage your tasks from
                anywhere, at any time.
              </p>
            </div>

            <div class="text">
              <span class="subtitle gradient-highlight">Find More Time</span>
              <h2>Chill Out and Relax</h2>
              <p>
                With your life back on track and your tasks efficiently managed, you can
                enjoy more time relaxing and rejuvenating. Take a well-deserved break,
                knowing that your responsibilities are under control and your goals are
                within reach.
              </p>
            </div>
          </div>
          <div class="right">
            <div class="container">
              <img src="/api/placeholder/600/400" alt="placeholder" />
            </div>
            <div class="container">
              <img src="/api/placeholder/600/400" alt="placeholder" />
            </div>
            <div class="container">
              <img src="/api/placeholder/600/400" alt="placeholder" />
            </div>
          </div>
        </section>
        """
    }

    func productDemo() -> String {
        """
        <section class="grid slant">
            <div class="text">
              <span class="subtitle gradient-highlight">Keep Up to Date</span>
              <h2>Swift Todos Makes Life Simpler</h2>
              <p>
                By keeping things simple Swift Todos allows you to focus on the tasks that really matter and achieving them, rather than spending your time building a whole system to track your tasks.
              </p>
            </div>
          <img src="/api/placeholder/600/400" alt="placeholder" />
        </section>
        """
    }

    func callToAction() -> String {
        """
        <section>
            <div class="cta">
                <div class="border-tracker"></div>
                <h2 class="gradient-highlight">Get Started Now</h2>
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
        \(productDemo())
        \(callToAction())
        """
    }
}
