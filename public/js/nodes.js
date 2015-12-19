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

  filterBox(".filter input", nodes);

  function build_list(top, title, array) {
    window.location.hash = '#'+title;
    top.innerHTML = "<h3>Node "+title+"</h3>";
    addTo(top, "<div class=\"paramfilter\"><input type=\"text\" name=\"paramfilter\" /></div>");
    if (array.length > 0) {
      Array.prototype.forEach.call(array, (item, i) => {
        Array.prototype.forEach.call(Object.keys(item), (param, ii) => {
          Array.prototype.forEach.call(item[param], (values, i) => {
            addTo(top,  "<div class=\"row\">" +
                        "<div class=\"paramfile\">"+shortParamFile(values['file'])+"</div>\n" +
                        "<div class=\"data\">"+param.replace(/\./g,' . ')+"</div>\n" +
                        "<div class=\"value\">"+values['value']+"</div>\n" +
                        "</div>");
          });
        });
      });
      var rows = document.querySelectorAll('div.row');
      filterBox(".paramfilter input", rows);

    } else {
      addTo(top, "<div>There is no params in this node.</div>\n");
    }
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

  if (window.location.hash != '') {
    var target = window.location.hash.replace(/#/,'');
    Array.prototype.forEach.call(nodes, (item, i) => {
      if (item.textContent == target) {
        var event = document.createEvent('HTMLEvents');
        event.initEvent('click', true, false);
        item.dispatchEvent(event);
      }
    });
  }

});
