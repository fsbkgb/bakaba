$(document).ready(function(){
 
        $("form").hide();
        $(".nthread").show();
 
    $('.nthread').click(function(){
    $("form").slideToggle("fast");
    });
 
});