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

function filterBox(input, els) {
  var filterinput = document.querySelector(input);
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

/* from https://github.com/ReactiveSets/toubkal/blob/master/lib/util/value_equals.js */
function equals( a, b, enforce_properties_order, cyclic ) {
  return a === b
    && a !== 0 
    || _equals( a, b ) 
  ;
  
  function _equals( a, b ) {
    var s, l, p, x, y;
    if ( ( s = toString.call( a ) ) !== toString.call( b ) ) return false;
    switch( s ) {
      default:
        return a.valueOf() === b.valueOf();
      case '[object Number]':
        a = +a;
        b = +b;
        return a ? 
            a === b
          :
            a === a ? 
            1/a === 1/b 
          : b !== b 
        ;
      case '[object RegExp]':
        return a.source   == b.source
          && a.global     == b.global
          && a.ignoreCase == b.ignoreCase
          && a.multiline  == b.multiline
          && a.lastIndex  == b.lastIndex
        ;
      case '[object Function]':
        return false;
      case '[object Array]':
        if ( cyclic && ( x = reference_equals( a, b ) ) !== null ) return x; 
        if ( ( l = a.length ) != b.length ) return false;
        while ( l-- ) {
          if ( ( x = a[ l ] ) === ( y = b[ l ] ) && x !== 0 || _equals( x, y ) ) continue;
          return false;
        }
        return true;
      case '[object Object]':
        if ( cyclic && ( x = reference_equals( a, b ) ) !== null ) return x; 
        l = 0; 
        if ( enforce_properties_order ) {
          var properties = [];
          for ( p in a ) {
            if ( a.hasOwnProperty( p ) ) {
              properties.push( p );
              if ( ( x = a[ p ] ) === ( y = b[ p ] ) && x !== 0 || _equals( x, y ) ) continue;
              return false;
            }
          }
          for ( p in b )
            if ( b.hasOwnProperty( p ) && properties[ l++ ] != p )
              return false;
        } else {
          for ( p in a ) {
            if ( a.hasOwnProperty( p ) ) {
              ++l;
              if ( ( x = a[ p ] ) === ( y = b[ p ] ) && x !== 0 || _equals( x, y ) ) continue;
              return false;
            }
          }
          for ( p in b )
            if ( b.hasOwnProperty( p ) && --l < 0 )
              return false;
        }
        return true;
    }
  }

  function reference_equals( a, b ) {
    var object_references = [];
    return ( reference_equals = _reference_equals )( a, b );
    function _reference_equals( a, b ) {
      var l = object_references.length;
      while ( l-- )
        if ( object_references[ l-- ] === b )
          return object_references[ l ] === a;
      object_references.push( a, b );
      return null;
    }
  }
}
