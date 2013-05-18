$(document).ready(function() {
  $("input:password").val(
    function(index, x) {
      if(x == ""){
        var chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        for(var i=0;i<8;i++) {
          var rnd=Math.floor(Math.random()*chars.length);
          x+=chars.substring(rnd,rnd+1);
        }
       return x;
       }
       else
       return x;
     }
   );		
});