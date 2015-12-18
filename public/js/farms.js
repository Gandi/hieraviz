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
  var meat = document.querySelector('pre.meat');

  function build_list(top, array) {
    top.textContent = '';
    Array.prototype.forEach.call(array, (item, i) => {
      top.insertAdjacentHTML("beforeend","<li>"+item+"</li>\n");
    });
  }

  Array.prototype.forEach.call(farms, (item, i) => {
    item.addEventListener('click', (ev) => {
      addClass(meat, 'wait');
      el = ev.target;
      fetch('/v1/farm/' + el.innerText).
        then(res => res.json()).
        then(j => {
          build_list(meat, j);
          Array.prototype.forEach.call(farms, (item, i) => {
            removeClass(item, 'focus')
          });
          addClass(el, 'focus');
          removeClass(meat, 'wait');
        });
    });
  });
});
