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
  if (document.readyState !== 'loading') {
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}

ready( () => {
  var farms = document.querySelectorAll('li.farm');
  var meat = document.querySelector('div.meat');
  var base = window.location.pathname.split('/')[1];
  focusNav('farms');
  filterBox(".side .filter input", farms);

  function restore_url(list) {
    if (window.location.hash !== '') {
      var target = window.location.hash.replace(/#/,'');
      var parts = target.split('/');
      Array.prototype.forEach.call(list, (item, i) => {
        if (item.textContent == parts[0]) {
          if (parts[1] != undefined) {
            Farm[parts[1]](parts[0]);
          } else {
            var event = document.createEvent('HTMLEvents');
            event.initEvent('click', true, false);
            item.dispatchEvent(event);
          }
        }
      });
    }
  }


  function build_list(top, title, hash) {
    window.location.hash = '#'+title;
    top.innerHTML = "<h3>Farm "+title+"</h3>";
    if (Object.keys(hash).length > 0) 
      Array.prototype.forEach.call(Object.keys(hash), (item, i) => {
        var node = document.createElement('div');
        node.className = "node";
        top.appendChild(node);
        var node_title = document.createElement('div');
        node_title.innerHTML = '<div><a href="/'+base+'/nodes#'+ item +'">' + item + '</a></div>';
        node.appendChild(node_title);
        Array.prototype.forEach.call(Object.keys(hash[item]), (itemvar, i) => {
          addTo(node, "<div>"+itemvar+": "+hash[item][itemvar]+"</div>")
        });
      });
    else
      addTo(top, "<div>There is no node in this farm.</div>\n");
  }

  function show_error(meat, message) {
    meat.innerHTML = "<div class=\"error\">" + message + "</div>\n";
  }


  var Farm = {
    show: function(el) {
      addClass(meat, 'wait');
      farm = el.dataset.item;
      fetch('/v1/' + base + '/farm/' + farm, auth_header()).
        then(res => res.json()).
        then(j => {
          if (j.error != undefined) {
            show_error(meat, j['error']);
          } else {
            build_list(meat, farm, j);
            Array.prototype.forEach.call(farms, (item, i) => {
              removeClass(item, 'focus');
            });
            addClass(el, 'focus');
            update_footer('/v1/' + base + '/farm/' + farm);
          }
          removeClass(meat, 'wait');
        });
    }
  };

  Array.prototype.forEach.call(farms, (item, i) => {
    item.addEventListener('click', (ev) => {
      Farm.show(ev.target);
    });
  });

  update_footer('/v1/' + base + '/farms');
  restore_url(farms);

});
