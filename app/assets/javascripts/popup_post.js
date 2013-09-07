$(function() {

  var oppost = $('.reflink')[0].getAttribute('id');
  
  $("[id^='popup_']").hover(function(e) {
    var reply_number = $(this).text().split(">>")[1];
    if ($('table#reply_'+reply_number).html()!= null) {
      var popup_content = $('table#reply_'+reply_number).html();
    } else if (oppost==reply_number) {
      var popup_content = '<div class="content"><p>OP post</p></div>';
    } else {
      var popup_content = '<div class="content"><p>Can`t find this post in the thread</p></div>';
    };
    $('div#pop-up').html(popup_content);
  },
  function() {
    $('div#pop-up').html(null);
  });

  $("[id^='popup_']").ezpz_tooltip({contentId:"pop-up"});

});