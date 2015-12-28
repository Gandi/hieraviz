/* 
We don't need jQuery fat mama
http://youmightnotneedjquery.com/
https://github.com/oneuijs/You-Dont-Need-jQuery

also
We don't need to care about freaking IE
let's use the fetch API for ajax calls
https://fetch.spec.whatwg.org
*/

ready( () => {

  var meat = document.querySelector('div.meat');
  var nodes = document.querySelectorAll('li.node');
  focusNav('nodes');
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

  function focus_on(els, el) {
    Array.prototype.forEach.call(els, (item, i) => {
      removeClass(item, 'focus');
    });
    addClass(el, 'focus');    
  }

  function build_top(title) {
    meat.innerHTML = "<h3>Node "+title+"</h3>";
    addTo(meat,  "<div class=\"nodenav\">" +
                 "<span class=\"showinfo\" data-node=\""+title+"\">Info</span>" +
                 "<span class=\"showparams\" data-node=\""+title+"\">Params</span>" +
                 "<span class=\"showallparams\" data-node=\""+title+"\">AllParams</span>" +
                 "</div>");
    addTo(meat,  "<div class=\"paramfilter\">" + 
                 "<input type=\"text\" name=\"paramfilter\" />" +
                 "</div>");
   }

  function build_info(top, title, hash) {

  }

  function build_params(top, title, hash) {
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


  function rebuild_nav(title) {
    var nodelinks = document.querySelectorAll('div.nodenav span');
    Array.prototype.forEach.call(nodelinks, (item, i) => {
      item.addEventListener('click', (ev) => {
        start_wait();
        el = ev.target;
        action = el.innerText.toLowerCase();
        fetch('/v1/node/' + title + '/' + action).
          then(res => res.json()).
          then(j => {
            focus_on(nodelinks, el);
            end_wait();
          });
      });
    });
  }

  var Node = {
    params: function(el) {
      start_wait(meat);
      title = el.dataset.node;
      fetch('/v1/node/' + title).
        then(res => res.json()).
        then(j => {
          build_top(title);
          build_params(meat, title, j);
          rebuild_nav(title);
          end_wait(meat);
        });
    },

    info: function(el) {
      start_wait(meat);
      title = el.dataset.node;
      fetch('/v1/node/' + title + '/info').
        then(res => res.json()).
        then(j => {
          build_top(title);
          build_info(meat, title, j);
          rebuild_nav(title);
          end_wait(meat);
        });
    },

  }

  /* declaration of events for the nodes menu */
  Array.prototype.forEach.call(nodes, (item, i) => {
    item.addEventListener('click', (ev) => {
      Node.params(ev.target);
    });
  });

  /* management of the hash navigation */
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
