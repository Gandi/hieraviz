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

function addClass(el, className) {
  if (el.classList)
    el.classList.add(className);
  else
    el.className += ' ' + className;
}

function removeClass(el, className) {
  if (el.classList)
    el.classList.remove(className);
  else
    el.className = el.className.replace(new RegExp('(^|\\b)' + className.split(' ').join('|') + '(\\b|$)', 'gi'), ' ');
}

function focusNav(className) {
  var nav = document.querySelectorAll('.nav a');
  Array.prototype.forEach.call(nav, (item, i) => {
    removeClass(item, 'focus')
  });
  var navFocus = document.querySelector('.nav a.' + className);
  addClass(navFocus, 'focus');
}

function addTo(el, txt) {
  el.insertAdjacentHTML("beforeend", txt);
}

function shortParamFile(path) {
  return path.replace(/params\//, '').replace(/\.yaml/, '');
}

function filterBox(els) {
  var filterinput = document.querySelector('.filter input');
  filterinput.focus();
  filterinput.addEventListener('keyup', (ev) => {
    el = ev.target;
    if (el.value == '') 
      Array.prototype.forEach.call(els, (item, i) => {
        item.style.display = 'block';
      });
    else
      Array.prototype.forEach.call(els, (item, i) => {
        if (item.innerText.match(el.value))
          item.style.display = 'block';
        else
          item.style.display = 'none';
      });
  });
}
