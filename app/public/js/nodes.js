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
  var base = window.location.pathname.split('/')[1];
  focusNav('nodes');
  filterBox(".side .filter input", nodes);

  function restore_url(list) {
    if (window.location.hash != '') {
      var target = window.location.hash.replace(/#/,'');
      var parts = target.split('/');
      Array.prototype.forEach.call(list, (item, i) => {
        if (item.textContent == parts[0]) {
          if (parts[1] != undefined) {
            Node[parts[1]](parts[0]);
          } else {
            var event = document.createEvent('HTMLEvents');
            event.initEvent('click', true, false);
            item.dispatchEvent(event);
          }
        }
      });
    }
  }


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
    meat.innerHTML = "";
    addTo(meat,  "<div class=\"filter\">" + 
                 "<h3>Node "+title+"</h3>" +
                 "<div class=\"nodenav\">" +
                 "<span class=\"showinfo\" data-item=\""+title+"\">Info</span>" +
                 "<span class=\"showparams\" data-item=\""+title+"\">Params</span>" +
                 "<span class=\"showallparams\" data-item=\""+title+"\">AllParams</span>" +
                 "</div><div class=\"paramfilter\">" + 
                 "<input type=\"text\" name=\"paramfilter\" />" +
                 "</div></div>");
   }

  function build_info(top, title, hash) {
    if (Object.keys(hash).length > 0) {
      var wrapper = document.createElement('div');
      wrapper.className = 'rows info';
      top.appendChild(wrapper);
      Array.prototype.forEach.call(Object.keys(hash), (item, k) => {
        addTo(wrapper,  "<div class=\"row\">" +
                        "<span class=\"infokey\">" + item + "</span>" +
                        "<span class=\"infovalue\">" + JSON.stringify(hash[item], null, 2) + "</span>" +
                        "</div");
      });
      var rows = document.querySelectorAll('div.row');
      filterBox(".paramfilter input", rows);
    } else {
      addTo(top, "<div>There is no params in this node.</div>\n");
    }
    window.location.hash = '#' + title +'/info';
  }

  function build_hierarchy(top, node) {
    var hierarchy = document.createElement('div');
    hierarchy.className = 'hierarchy';
    top.insertBefore(hierarchy, top.firstChild);
    fetch('/v1/' + base + '/node/' + node + '/hierarchy', auth_header()).
      then(res => res.json()).
      then(j => {
        var hierachy = document.querySelector('div.hierarchy');
        if (j.error != undefined) {
          show_error(hierachy, j['error']);
        } else {
          console.debug(j);
          addTo(hierarchy, "<h3>From hiera config</h3>");
          var hierafiles = document.createElement('div');
          hierafiles.className = "hierafiles";
          hierarchy.appendChild(hierafiles);
          Array.prototype.forEach.call(Object.keys(j.hiera), (item, k) => {
            addTo(hierafiles, "<div>"+j.hiera[item]+"</div>");
          });
          addTo(hierarchy, "<h3>From Node Data</h3>");
          var nodeinfo = document.createElement('div');
          nodeinfo.className = "nodeinfo";
          hierarchy.appendChild(nodeinfo);
          Array.prototype.forEach.call(Object.keys(j.info), (item, k) => {
            var index = j.vars.indexOf(item);
            if (index > -1) {
              addTo(nodeinfo, "<div class=\"var\"><div class=\"label\">"+item+"</div><div><input type=\"text\" name=\""+item+"\" value=\""+j.info[item]+"\"></div></div>");
              j.vars.splice(index, 1);
            }
          });
          addTo(hierarchy, "<h3>From Facts</h3>");
          var factinfo = document.createElement('div');
          factinfo.className = "factinfo";
          hierarchy.appendChild(factinfo);
          Array.prototype.forEach.call(Object.keys(j.vars), (item, k) => {
            addTo(factinfo, "<div class=\"var\"><div class=\"label\">"+j.vars[item]+"</div><div><input type=\"text\" name=\""+j.vars[item]+"\" value=\""+"\"></div></div>");
          });
          addTo(hierarchy, "<h3>Resulting files</h3>");
          var nodefiles = document.createElement('div');
          nodefiles.className = "nodefiles";
          hierarchy.appendChild(nodefiles);
          Array.prototype.forEach.call(Object.keys(j.files), (item, k) => {
            addTo(nodefiles, "<div>"+j.files[item]+"</div>");
          });
        }
      });
  }

  function build_params(top, title, hash) {
    if (Object.keys(hash).length > 0) {
      var wrapper = document.createElement('div');
      wrapper.className = 'rows';
      top.appendChild(wrapper);
      Array.prototype.forEach.call(Object.keys(hash), (item, k) => {
        build_row(wrapper, item, hash[item]);
      });
      var rows = document.querySelectorAll('div.row');
      filterBox(".paramfilter input", rows);
      build_hierarchy(top, title);
    } else {
      addTo(top, "<div>There is no params in this node.</div>\n");
    }
    window.location.hash = '#'+title;
  }


  function rebuild_nav(title) {
    var nodelinks = document.querySelectorAll('div.nodenav span');
    Array.prototype.forEach.call(nodelinks, (item, i) => {
      item.addEventListener('click', (ev) => {
        el = ev.target;
        action = el.textContent.toLowerCase();
        Node[action](el.dataset.item);
      });
    });
  }

  function show_error(meat, message) {
    meat.innerHTML = "<div class=\"error\">" + message + "</div>\n";
  }

  var Node = {
    params: function(node) {
      start_wait(meat);
      fetch('/v1/' + base + '/node/' + node, auth_header()).
        then(res => res.json()).
        then(j => {
          // console.log(auth_header().headers.getAll('x-auth'));
          build_top(node);
          if (j.error != undefined) {
            show_error(meat, j['error']);
          } else {
            build_params(meat, node, j);
            rebuild_nav(node);
            update_footer('/v1/' + base + '/node/' + node);
            but = document.querySelector('.showparams');
            addClass(but, 'focus');
          }
          end_wait(meat);
        });
    },

    info: function(node) {
      start_wait(meat);
      fetch('/v1/' + base + '/node/' + node + '/info', auth_header()).
        then(res => res.json()).
        then(j => {
          build_top(node);
          if (j.error != undefined) {
            show_error(meat, j['error']);
          } else {
            build_info(meat, node, j);
            rebuild_nav(node);
            update_footer('/v1/' + base + '/node/' + node + '/info');
            but = document.querySelector('.showinfo');
            addClass(but, 'focus');
          }
          end_wait(meat);
        });
    },

    allparams: function(node) {
      start_wait(meat);
      fetch('/v1/' + base + '/node/' + node + '/allparams', auth_header()).
        then(res => res.json()).
        then(j => {
          build_top(node);
          if (j.error != undefined) {
            show_error(meat, j['error']);
          } else {
            build_params(meat, node, j);
            rebuild_nav(node);
            update_footer('/v1/' + base + '/node/' + node + '/allparams');
            but = document.querySelector('.showallparams');
            addClass(but, 'focus');
          }
          end_wait(meat);
        });
    },
  }

  /* declaration of events for the nodes menu */
  Array.prototype.forEach.call(nodes, (item, i) => {
    item.addEventListener('click', (ev) => {
      Node.params(ev.target.textContent);
    });
  });

  update_footer('/v1/' + base + '/nodes');
  restore_url(nodes);

});
