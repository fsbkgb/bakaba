popupPost = function(e) {
    mouseX = e.pageX; 
    mouseY = e.pageY;
    oppost = $('.reflink')[0].getAttribute('id');
    post = this.id.match(/\d+/); 
    reply_number = $(this).text().split(">>")[1];
    reply_id = 'pop-up'+post;
    if ($('div#'+reply_id).length == 0) {
      $(".thread").append('<div id="'+reply_id+'"></div>');
    };
    if ($('table#reply_'+reply_number).html()!= null) {
      popup_content = $('table#reply_'+reply_number).html();
    } else if (oppost==reply_number) {
      popup_content = '<div class="content"><p>OP post</p></div>';
    } else {
      popup_content = '<div class="content"><p>Can`t find this post in the thread</p></div>';
    };
    popup_conteiner = $('div#'+reply_id);
    popup_conteiner.html(popup_content);
    popup_conteiner.css({'top':mouseY,'left':mouseX}).show();
    popup_conteiner.on("mouseleave", function(e) {
     $(this).fadeOut(200, function() {
       $(this).remove();
     });
    });
  }
  
$('.thread').on('mouseenter', '[id^="popup_"]', popupPost);
  