// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function moreMotionsInitializer() {
  $('ul.motions + .show_more a').live('click', function(e) {
    var link = $(this);
    if (link.hasClass('disabled')) return;

    link.text('Loading...').addClass('disabled');
    $.getScript(this.href);

    e.preventDefault();
  });
}

function highlightFade() {
  $('.highlight_fade').animate({backgroundColor : '#ffffff'}, 3000);
}

$(document).ready(function(){
    moreMotionsInitializer();
    highlightFade();
});
