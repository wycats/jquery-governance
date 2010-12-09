// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function(){
  $('.more_motions').live('click', function(){
    var self = $(this);
    var data = {state: self.attr('data-state'), id: self.attr('data-last-id')};
    var ul = self.closest("section").find("ul");
    self.remove();
    $.get("/motions/show_more", data, function(html) {
      $(ul).append(html);
    });
  });
});
