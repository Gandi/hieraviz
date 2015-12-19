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

function deepCompare() {
  var i, l, leftChain, rightChain;
  function compare2Objects (x, y) {
    var p;
    if (isNaN(x) && isNaN(y) && typeof x === 'number' && typeof y === 'number') {
      return true;
    }
    if (x === y) {
      return true;
    }
    if ((typeof x === 'function' && typeof y === 'function') ||
       (x instanceof Date && y instanceof Date) ||
       (x instanceof RegExp && y instanceof RegExp) ||
       (x instanceof String && y instanceof String) ||
       (x instanceof Number && y instanceof Number)) {
      return x.toString() === y.toString();
    }
    if (!(x instanceof Object && y instanceof Object)) {
      return false;
    }
    if (x.isPrototypeOf(y) || y.isPrototypeOf(x)) {
      return false;
    }
    if (x.constructor !== y.constructor) {
      return false;
    }
    if (x.prototype !== y.prototype) {
      return false;
    }
    if (leftChain.indexOf(x) > -1 || rightChain.indexOf(y) > -1) {
      return false;
    }
    for (p in y) {
      if (y.hasOwnProperty(p) !== x.hasOwnProperty(p)) {
        return false;
      } else if (typeof y[p] !== typeof x[p]) {
        return false;
      }
    }
    for (p in x) {
      if (y.hasOwnProperty(p) !== x.hasOwnProperty(p)) {
        return false;
      } else if (typeof y[p] !== typeof x[p]) {
        return false;
      }
      switch (typeof (x[p])) {
      case 'object':
      case 'function':
        leftChain.push(x);
        rightChain.push(y);
        if (!compare2Objects (x[p], y[p])) {
          return false;
        }
        leftChain.pop();
        rightChain.pop();
        break;
      default:
        if (x[p] !== y[p]) {
          return false;
        }
        break;
      }
    }
    return true;
  }
  if (arguments.length < 1) {
    return true;
  }
  for (i = 1, l = arguments.length; i < l; i++) {
    leftChain = [];
    rightChain = [];
    if (!compare2Objects(arguments[0], arguments[i])) {
      return false;
    }
  }
  return true;
}

/* from https://github.com/ReactiveSets/toubkal/blob/master/lib/util/value_equals.js */
function equals( a, b, enforce_properties_order, cyclic ) {
  return a === b
    && a !== 0         // because 0 === -0, requires test by _equals()
    || _equals( a, b ) // handles not strictly equal or zero values
  ;
  
  function _equals( a, b ) {
    // a and b have already failed test for strict equality or are zero
    
    var s, l, p, x, y;
    
    // They should have the same toString() signature
    if ( ( s = toString.call( a ) ) !== toString.call( b ) ) return false;
    
    switch( s ) {
      default: // Boolean, Date, String
        return a.valueOf() === b.valueOf();
      
      case '[object Number]':
        // Converts Number instances into primitive values
        // This is required also for NaN test bellow
        a = +a;
        b = +b;
        
        return a ?         // a is Non-zero and Non-NaN
            a === b
          :                // a is 0, -0 or NaN
            a === a ?      // a is 0 or -O
            1/a === 1/b    // 1/0 !== 1/-0 because Infinity !== -Infinity
          : b !== b        // NaN, the only Number not equal to itself!
        ;
      // [object Number]
      
      case '[object RegExp]':
        return a.source   == b.source
          && a.global     == b.global
          && a.ignoreCase == b.ignoreCase
          && a.multiline  == b.multiline
          && a.lastIndex  == b.lastIndex
        ;
      // [object RegExp]
      
      case '[object Function]':
        return false; // functions should be strictly equal because of closure context
      // [object Function]
      
      case '[object Array]':
        if ( cyclic && ( x = reference_equals( a, b ) ) !== null ) return x; // intentionally duplicated bellow for [object Object]
        
        if ( ( l = a.length ) != b.length ) return false;
        // Both have as many elements
        
        while ( l-- ) {
          if ( ( x = a[ l ] ) === ( y = b[ l ] ) && x !== 0 || _equals( x, y ) ) continue;
          
          return false;
        }
        
        return true;
      // [object Array]
      
      case '[object Object]':
        if ( cyclic && ( x = reference_equals( a, b ) ) !== null ) return x; // intentionally duplicated from above for [object Array]
        
        l = 0; // counter of own properties
        
        if ( enforce_properties_order ) {
          var properties = [];
          
          for ( p in a ) {
            if ( a.hasOwnProperty( p ) ) {
              properties.push( p );
              
              if ( ( x = a[ p ] ) === ( y = b[ p ] ) && x !== 0 || _equals( x, y ) ) continue;
              
              return false;
            }
          }
          
          // Check if 'b' has as the same properties as 'a' in the same order
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
          
          // Check if 'b' has as not more own properties than 'a'
          for ( p in b )
            if ( b.hasOwnProperty( p ) && --l < 0 )
              return false;
        }
        
        return true;
      // [object Object]
    } // switch toString.call( a )
  } // _equals()
  
  /* -----------------------------------------------------------------------------------------
     reference_equals( a, b )
     
     Helper function to compare object references on cyclic objects or arrays.
     
     Returns:
       - null if a or b is not part of a cycle, adding them to object_references array
       - true: same cycle found for a and b
       - false: different cycle found for a and b
     
     On the first call of a specific invocation of equal(), replaces self with inner function
     holding object_references array object in closure context.
     
     This allows to create a context only if and when an invocation of equal() compares
     objects or arrays.
  */
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
  } // reference_equals()
}
