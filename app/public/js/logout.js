ready( () => {

  fetch('/', {
    credentials: 'include',
    headers: {
      "Authorization": "Basic blah"
    }
  }).then( () => {
      window.location = "/";
    }
  );

});
