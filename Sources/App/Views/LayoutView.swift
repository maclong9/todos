import Foundation

struct LayoutView {
    let title: String
    let description: String
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
              <button class="unstyle menu-icon" onclick="toggleMenu()">
                <span></span>
                <span></span>
                <span></span>
              </button>
              <nav>\(ActionButtons(isNavigation: true).render())</nav>
            </header>
            <main>\(content)</main>
            <footer>
              <small>
                © \(Calendar.current.component(.year, from: Date())) -
                <a href="https://github.com/maclong9">Mac Long</a>
              </small>
            </footer>
            <script>
              // Define navigation elements
              const menuIcon = document.querySelector(".menu-icon");
              const dropdown = document.querySelector("nav");

              /**
               * Toggles the menu icon animation and dropdown visibility
               * @function toggleMenu
               * @description Toggles the 'active' class on both the menu icon and dropdown elements
               * @returns {void}
               * @example
               * <button onclick="toggleMenu()">Toggle Menu</button>
               */
              function toggleMenu() {
                menuIcon.classList.toggle("active");
                dropdown.classList.toggle("active");
              }

              /**
               * Event listener for handling clicks outside the menu
               * @function
               * @param {MouseEvent} event - The click event object
               * @description Closes the dropdown menu when clicking outside of the menu icon or dropdown area
               * @listens document#click
               */
              document.addEventListener("click", function (event) {
                if (
                  !menuIcon.contains(event.target) &&
                  !dropdown.contains(event.target)
                ) {
                  menuIcon.classList.remove("active");
                  dropdown.classList.remove("active");
                }
              });
            </script>
          </body>
        </html>
        """
    }
}
