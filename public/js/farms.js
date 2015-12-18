/* 
We don't need jQuery fat mama
http://youmightnotneedjquery.com/
https://github.com/oneuijs/You-Dont-Need-jQuery

also
We don't need to care about freaking IE
let's use the fetch API for ajax calls
https://fetch.spec.whatwg.org
*/

function ready(fn) {
  if (document.readyState != 'loading') {
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}

ready( () => {
  focusNav('farms');

  var farms = document.querySelectorAll('li.farm');
  var meat = document.querySelector('div.meat');

  filterBox(farms);

  function build_list(top, title, array) {
    top.innerHTML = "<h3>Farm "+title+"</h3>";
    if (array.length > 0)
      Array.prototype.forEach.call(array, (item, i) => {
        addTo(top, "<div>"+item+"</div>\n");
      });
    else
      addTo(top, "<div>There is no node in this farm.</div>\n");
  }

  Array.prototype.forEach.call(farms, (item, i) => {
    item.addEventListener('click', (ev) => {
      addClass(meat, 'wait');
      el = ev.target;
      fetch('/v1/farm/' + el.innerText).
        then(res => res.json()).
        then(j => {
          build_list(meat, el.innerText, j);
          Array.prototype.forEach.call(farms, (item, i) => {
            removeClass(item, 'focus')
          });
          addClass(el, 'focus');
          removeClass(meat, 'wait');
        });
    });
  });
});
