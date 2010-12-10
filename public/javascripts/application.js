// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function(){
  $('a.more_motions').live('click', function(e){
    var self = $(this);
    var data = {id: self.attr('data-last-id')};
    var ul = self.closest("section").find("ul");
    self.remove();
    $.get("/motions/show_more", data, function(html) {
      var divIndex = html.indexOf('<div');
      if (divIndex > 0) {
        // pull out the More link if it exists and append it outside the UL
        var moreHTML = html.substring(divIndex);
        html = html.replace(/<div.*<\/div>/, '');
        $(ul).after(moreHTML);
      };
      $(ul).append(html);
    });
    e.preventDefault();
  });
});
