/**
 * Event listener for toggling the mobile menu
 * @param {MouseEvent} event - The click event object
 */
document.addEventListener("click", ({ target }) => {
  const isMenuClick = target.closest(".menu-icon");
  const isOutside = !target.closest("nav");
  const action = isMenuClick ? "toggle" : isOutside ? "remove" : "add";

  [".menu-icon", "header nav"].map((selector) =>
    document.querySelector(selector)?.classList[action]("active"),
  );
});
