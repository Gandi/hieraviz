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
  focusNav('nodes');

  var nodes = document.querySelectorAll('li.node');
  var meat = document.querySelector('div.meat');
  // var debugarea = document.querySelector('span.debug');

  filterBox(nodes);

  function build_list(top, title, array) {
    top.innerHTML = "<h3>Node "+title+"</h3>";
    if (array.length > 0)
      Array.prototype.forEach.call(array, (item, i) => {
        Array.prototype.forEach.call(Object.keys(item), (param, ii) => {
          Array.prototype.forEach.call(item[param], (values, i) => {
            addTo(top,  "<div class=\"row\">" +
                        "<span class=\"paramfile\">"+shortParamFile(values['file'])+"</span>\n" +
                        "<span class=\"data\">"+param+"</span>\n" +
                        "<br><span class=\"value\">"+values['value']+"</span>\n" +
                        "</div>");
          });
        });
      });
    else
      addTo(top, "<div>There is no params in this node.</div>\n");
  }

  Array.prototype.forEach.call(nodes, (item, i) => {
    item.addEventListener('click', (ev) => {
      addClass(meat, 'wait');
      el = ev.target;
      fetch('/v1/node/' + el.innerText).
        then(res => res.json()).
        then(j => {
          build_list(meat, el.innerText, j);
          Array.prototype.forEach.call(nodes, (item, i) => {
            removeClass(item, 'focus')
          });
          addClass(el, 'focus')
          removeClass(meat, 'wait');
        });
    });
  });

});
