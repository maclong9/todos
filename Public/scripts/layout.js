/**
 * Event listener for toggling the mobile menu
 */
document.addEventListener("click", e => {
    const menuBtn = document.querySelector(".menu-icon");
    const nav = document.querySelector("header nav");
    const isMenuClick = e.target.closest(".menu-icon");
    const isVisible = nav.classList.contains("active");
    
    if (isMenuClick || (!e.target.closest("header nav") && isVisible)) {
        const newState = isMenuClick ? !isVisible : false;
        menuBtn.classList.toggle("active", newState);
        nav.classList.toggle("active", newState);
        menuBtn.setAttribute("aria-expanded", newState);
    }
});
