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

  var input  = $('input[type=text][name$="[conflicts_list]"]');
  var button = $('<a class="button add">add</a>').click(function() {
    var conflict = $.trim(input.val());
    if (conflict == '') return;

    var remove = $('<a class="remove">remove</a>').click(function() {
      $(this).parent().remove();
    });

    $('<li><span class="badge">' + conflict + '</span> </li>')
      .append(remove)
      .appendTo(input.siblings('ul'));

    input.val('');
  });

  $.getJSON('/conflicts', function(data, status, xhr) {
    input.autocomplete({
      minLength: 0,
      source: data
    }).after('<ul class="conflicts"></ul>').after(button);
  });

  input.closest('form').submit(function() {
    var conflict_list = input.siblings('ul').find('li span').map(function() {
      return $(this).text();
    }).get().join(', ');
    $(this).append('<input type="hidden" name="' + input.attr('name') + '" value="' + conflict_list + '" />');
  });

  input.before(
    '<div class="instructions">' +
      '<p>Please add the companies which are related to the vote.</p>' +
      '<p>This will prevent members involved with them from voting.</p>' +
    '</div>'
  );
});
