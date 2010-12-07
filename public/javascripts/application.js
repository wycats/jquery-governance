// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function(){
  $('.more_motions').live('click', function(){
    var clickedId = $(this).attr('id');
    var motionState = clickedId.replace('motion_state_', '').replace('_link', '');
    $('#' + clickedId).remove();
    var lastDisplayedId = $('.motion_state_' + motionState + ':last').attr('id').replace('motion_', '');
    $.ajax({
      type: 'get',
      data: 'id=' + lastDisplayedId + '&state=' + motionState,
      url: '/motions/show_more',
      success: function(html){
        $('#motion_state_' + motionState + '_section').append(html);
        // TODO: make the 'More' link reappear if there are even more records
      }
    });
  });
});
