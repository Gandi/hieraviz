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

  function build_row(top, param, values, overriden, alone) {
    if (overriden) {
      rowclass = "row overriden";
    } else {
      rowclass = "row";
    }
    if (!overriden && !equals(values['merged'], values['value']) && !alone) {
      merged = JSON.stringify(values['merged'], null, 2);
      value = JSON.stringify(values['value'], null, 2);
      addTo(top,  "<div class=\""+rowclass+"\">" +
                  "<div class=\"paramfile\">- merged -</div>\n" +
                  "<div class=\"data\">"+param.replace(/\./g,' . ')+"</div>\n" +
                  "<pre class=\"value\">"+merged+"</pre>\n" +
                  "</div>");
      addTo(top,  "<div class=\"row overriden\">" +
                  "<div class=\"paramfile\">"+shortParamFile(values['file'])+"</div>\n" +
                  "<div class=\"data\">"+param.replace(/\./g,' . ')+"</div>\n" +
                  "<pre class=\"value\">"+value+"</pre>\n" +
                  "</div>");
    } else {
      merged = JSON.stringify(values['merged'], null, 2);
      addTo(top,  "<div class=\""+rowclass+"\">" +
                  "<div class=\"paramfile\">"+shortParamFile(values['file'])+"</div>\n" +
                  "<div class=\"data\">"+param.replace(/\./g,' . ')+"</div>\n" +
                  "<pre class=\"value\">"+merged+"</pre>\n" +
                  "</div>");
    }
  }

  function build_list(top, title, array) {
    top.innerHTML = "<h3>Node "+title+"</h3>";
    addTo(top, "<div class=\"paramfilter\"><input type=\"text\" name=\"paramfilter\" /></div>");
    if (array.length > 0) {
      Array.prototype.forEach.call(array, (item, i) => {
        Array.prototype.forEach.call(Object.keys(item), (param, ii) => {
          first = item[param].shift();
          build_row(top, param, first, false, true);
          if (item[param].length > 0) {
            Array.prototype.forEach.call(item[param], (values, i) => {
              build_row(top, param, values, true, false);
            });
          }
        });
      });
      var rows = document.querySelectorAll('div.row');
      filterBox(".paramfilter input", rows);

    } else {
      addTo(top, "<div>There is no params in this node.</div>\n");
    }
    window.location.hash = '#'+title;
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
    window.location.hash = '#'+target;
  }

});
