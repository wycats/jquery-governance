// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function moreMotionsInitializer() {
  $('a.more_motions').live('click', function(e){
    var self = $(this);
    var data = {id: self.attr('data-last-id')};
    var ul = self.closest("section").find("ul");
    self.parent().remove();
    $.get("/motions/show_more", data, function(html) {
      $(ul).append(html);
    });
    e.preventDefault();
  });

  $('ul.motions:not(:has(li.last))').after(
    '<div class="show_more">' +
      '<a class="button more" href="/motions/show_more">More</a>' +
    '</div>'
  );

  $('ul.motions + .show_more a').live('click', function(e) {
    var link = $(this);
    if (link.hasClass('disabled')) return;

    link.text('Loading...').addClass('disabled');

    var container = link.parent();
    var ul        = container.prev('ul');
    var id        = ul.find('li:not(.no-border)').last().attr('id').replace(/[^0-9]+/, '');

    $.get(this.href, { id: id }, function(html) {
      ul.append(html);
      link.text('More').removeClass('disabled');

      if (ul.children('li.last').length > 0) {
         container.remove();
       }
    });

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
