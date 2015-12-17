/* 
We don't need jQuery fat mama
http://youmightnotneedjquery.com/
https://github.com/oneuijs/You-Dont-Need-jQuery

also
We don't need to care about freaking IE
let's use the fetch API for ajax calls
https://fetch.spec.whatwg.org
*/

var clicker = document.querySelector('#click');
var area = document.querySelector('#area');

clicker.addEventListener('click', function(el) {
  fetch('/test').
    then(res => res.json()).
    then((j) => {
      area.textContent = j['data'];
    });
});
