/* 
We don't need jQuery fat mama
http://youmightnotneedjquery.com/
https://github.com/oneuijs/You-Dont-Need-jQuery

also
We don't need to care about freaking IE
let's use the fetch API for ajax calls
https://fetch.spec.whatwg.org
*/

// "use strict";

function ready(fn) {
  if (document.readyState != 'loading') {
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}

var meat = document.querySelector('div.meat');

function make_base_auth(user, password) {
  var tok = user + ':' + password;
  var hash = btoa(tok);
  return "Basic " + hash;
}

function addClass(el, className) {
  if (el.classList !== null)
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

function filterBox(input, els) {
  var filterinput = document.querySelector(input);
  if (filterinput !== null) {
    filterinput.focus();
    filterinput.addEventListener('keyup', (ev) => {
      el = ev.target;
      if (el.value === '') 
        Array.prototype.forEach.call(els, (item, i) => {
          item.style.display = 'block';
        });
      else
        Array.prototype.forEach.call(els, (item, i) => {
          if (item.textContent.match(el.value))
            item.style.display = 'block';
          else
            item.style.display = 'none';
        });
    });
  }
}

function start_wait(meat) {
  addClass(meat, 'wait');
}

function end_wait(meat) {
  removeClass(meat, 'wait');
}

function update_footer(path) {
  var debug = document.querySelector('.foot .debug');
  console.log(window.location);
  debug.innerHTML = "curl -ks " + window.location.origin + path + " | jq '.'";
}


function auth_header() {
  var h = new Headers({"x-auth": session_key});
  return { headers: h }
}

function restore_url(list, someclass) {
  if (window.location.hash !== '') {
    var target = window.location.hash.replace(/#/,'');
    var parts = target.split('/');
    Array.prototype.forEach.call(list, (item, i) => {
      if (item.textContent.split(' ')[0] === parts[0]) {
        if (parts[1] !== undefined) {
          someclass[parts[1]](parts[0]);
        } else {
          var event = document.createEvent('HTMLEvents');
          event.initEvent('click', true, false);
          item.dispatchEvent(event);
        }
      }
    });
  }
}

ready( () => {

  var meat = document.querySelector('div.meat');

  var flash = document.querySelectorAll('div.flash');
  Array.prototype.forEach.call(flash, (item, i) => {
    item.addEventListener('click', (ev) => {
      ev.target.style.display = 'none';
    });
  });

  var login = document.querySelector('#login');
  if (login != null) {
    login.addEventListener('click', (ev) => {
      start_wait(meat);
    });
  }

});
