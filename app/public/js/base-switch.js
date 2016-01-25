
ready( () => {
  var bases = document.querySelectorAll('.base .all .select');
  filterBox(".base .all .filter input", bases);

  /* declaration of events for the bases menu */
  Array.prototype.forEach.call(bases, (item, i) => {
    item.addEventListener('click', (ev) => {
      
    });
  });

});
