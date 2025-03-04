import Foundation

/// The main layout wrapper for all pages in the application.
///
/// Provides consistent HTML structure including:
/// - Meta tags and SEO optimization
/// - Navigation header with authentication buttons
/// - Content area for page-specific views
/// - Footer with copyright information
///
/// - Parameters:
///    - title: Page title for the browser tab
///    - description: Meta description for SEO
///    - isLoggedIn: Authentication state for navigation options
///    - content: The main page content to be rendered
struct LayoutView {
  let title: String
  let description: String
  let isLoggedIn: Bool
  let content: String

  func render() -> String {
    """
    <!doctype html>
    <html lang="en">
        <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <title>\(title) | Swift Todos</title>
            <meta name="description" content="\(description)" />
            <meta property="og:image" content="images/hero.svg" />
            <meta
                name="apple-itunes-app"
                content="app-id=APP_ID,affiliate-data=AFFILIATE_ID,app-argument=SOME_TEXT"
            />
            <link rel="stylesheet" href="styles.css" />
            <link rel="icon" href="images/icon.svg" />
        </head>
        <body>
            <header>
                <a id="logo" href="/">Swift Todos</a>
                <nav id="main-navigation" popover>
                    \(ActionButtons(isNavigation: true, isLoggedIn: isLoggedIn).render())
                </nav>
                <button
                    class="unstyle menu-icon"
                    aria-label="Toggle menu"
                    popovertarget="main-navigation"
                >
                    <span></span>
                    <span></span>
                    <span></span>
                </button>
            </header>
            <main>\(content)</main>
            <footer>
                <small>
                    © \(Calendar.current.component(.year, from: Date())) -
                    <a href="https://github.com/maclong9">Mac Long</a>
                </small>
            </footer>
        </body>
    </html>
    """
  }
}
