
ready( () => {
  var bases = document.querySelectorAll('.base .all .select');
  var button = document.querySelector(".base .current");
  var menu = document.querySelector(".base .all");
  var menuvisible = false;
  filterBox(".base .all .filter input", bases);

  button.addEventListener('click', (ev) => {
    if (menuvisible) {
      removeClass(menu, "focus");
    } else {
      addClass(menu, "focus");
    }
    menuvisible = !menuvisible;
  });

  /* declaration of events for the bases menu */
  Array.prototype.forEach.call(bases, (item, i) => {
    item.addEventListener('click', (ev) => {
      var url = window.location;
      url.pathname = url.pathname.replace(/^\/[^\/]+/,"/"+ev.target.textContent);
    });
  });

});
