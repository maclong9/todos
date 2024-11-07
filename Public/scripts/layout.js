/**
 * Event listener for toggling the mobile menu
 * @param {MouseEvent} event - The click event object
 */
document.addEventListener("click", ({ target }) => {
    const menuButton = document.querySelector(".menu-icon");
    const nav = document.querySelector("header nav");
    const isMenuClick = target.closest(".menu-icon");
    const isOutside = !target.closest("nav");
    const action = isMenuClick ? "toggle" : isOutside ? "remove" : "add";

    if (menuButton && nav) {
        menuButton.classList[action]("active");
        nav.classList[action]("active");
        
        menuButton.setAttribute(
            "aria-expanded",
            nav.classList.contains("active").toString()
        );
    }
});
