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

  // var nodes = document.querySelectorAll('li.node');
  // var meat = document.querySelector('pre.meat');

  // Array.prototype.forEach.call(nodes, (item, i) => {
  //   item.addEventListener('click', (ev) => {
  //     el = ev.target;
  //     fetch('/v1/node/' + el.innerText).
  //       then(res => res.json()).
  //       then(j => {
  //         meat.textContent = JSON.stringify(j);
  //         Array.prototype.forEach.call(nodes, (item, i) => {
  //           removeClass(item, 'focus')
  //         });
  //         addClass(el, 'focus')
  //       });
  //   });
  // });
});
