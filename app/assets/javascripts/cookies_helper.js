//helper functions from https://www.quirksmode.org/js/cookies.html
function createCookie(name, value, days) {
  var expires;

  if (days) {
    var date = new Date();
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    expires = "; expires=" + date.toGMTString();
  } else {
    expires = "";
  }
  document.cookie = encodeURIComponent(name) + "=" + encodeURIComponent(value) + expires + "; path=/";
}

function readCookie(name) {
  var nameEQ = encodeURIComponent(name) + "=";
  var ca = document.cookie.split(';');
  for (var i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) === ' ') c = c.substring(1, c.length);
    if (c.indexOf(nameEQ) === 0) return decodeURIComponent(c.substring(nameEQ.length, c.length));
  }
  return null;
}

function eraseCookie(name) {
  createCookie(name, "", -1);
}


jQuery(document).ready(function () {
    if (readCookie("_disabled_site") === 'hide') {
    jQuery('#disabled_site_message').hide();
  }

  jQuery('#disabled_site_message  .closebtn').on('click', function () {
    jQuery('#disabled_site_message').hide();
    createCookie('_disabled_site', 'hide', 14);
  });

});
