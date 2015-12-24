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

  filterBox(".filter input", nodes);

  function build_line(top, file, key, value, overriden) {
    if (overriden === true) {
      rowclass = "row overriden";
    } else {
      rowclass = "row";
    }
    addTo(top,  "<div class=\""+rowclass+"\">" +
                "<div class=\"paramfile\">"+shortParamFile(file)+"</div>\n" +
                "<div class=\"data\">"+key.replace(/\./g,' . ')+"</div>\n" +
                "<pre class=\"value\">"+JSON.stringify(value, null, 2)+"</pre>\n" +
                "</div>");
  }

  function build_row(top, key, params) {
    build_line(top, params['file'], key, params['value'], false);
    if (params['overriden'] == true) {
      Array.prototype.forEach.call(params['found_in'], (values, i) => {
        build_line(top, values['file'], key, values['value'], true);
      });
    }
  }

  function rebuild_nav(title) {
    var nodelinks = document.querySelectorAll('div.nodenav span');
    Array.prototype.forEach.call(nodelinks, (item, i) => {
      item.addEventListener('click', (ev) => {
        addClass(meat, 'wait');
        el = ev.target;
        action = el.innerText.toLowerCase();
        fetch('/v1/node/' + title + '/' + action).
          then(res => res.json()).
          then(j => {

            Array.prototype.forEach.call(nodelinks, (item, i) => {
              removeClass(item, 'focus');
            });
            addClass(el, 'focus');
            removeClass(meat, 'wait');

          });
      });
    });
  }

  function build_params(top, title, hash) {
    top.innerHTML = "<h3>Node "+title+"</h3>";
    addTo(top,  "<div class=\"nodenav\">" +
                "<span class=\"showinfo\">Info</span>" +
                "<span class=\"showparams focus\">Params</span>" +
                "<span class=\"showallparams\">AllParams</span>" +
                "</div>");
    addTo(top,  "<div class=\"paramfilter\">" + 
                "<input type=\"text\" name=\"paramfilter\" />" +
                "</div>");
    if (Object.keys(hash).length > 0) {
      Array.prototype.forEach.call(Object.keys(hash), (item, k) => {
        build_row(top, item, hash[item]);
      });
      var rows = document.querySelectorAll('div.row');
      filterBox(".paramfilter input", rows);
    } else {
      addTo(top, "<div>There is no params in this node.</div>\n");
    }
    window.location.hash = '#'+title;
  }

  function get_nodeparams(title) {
    fetch('/v1/node/' + title).
      then(res => res.json()).
      then(j => {
        build_params(meat, title, j);
        rebuild_nav(title);
        Array.prototype.forEach.call(nodes, (item, i) => {
          removeClass(item, 'focus');
        });
        addClass(el, 'focus');
        removeClass(meat, 'wait');
      });
  }

  Array.prototype.forEach.call(nodes, (item, i) => {
    item.addEventListener('click', (ev) => {
      addClass(meat, 'wait');
      el = ev.target;
      get_nodeparams(el.innerText);
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
