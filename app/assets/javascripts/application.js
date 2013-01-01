// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .
$(document).ready(function() {
							
		$(".nthread").click(function(){
        $("form").slideToggle("fast");
        $(this).toggleClass("active");
    	});	
    	
	    $("input:password").val(
			function(index, x)
			{
	    		if(x == ""){
	    			var chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
					for(var i=0;i<8;i++)
					{
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