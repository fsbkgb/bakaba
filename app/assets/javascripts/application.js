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
		$('.styleswitch').click(function()
		{
			switchStylestyle(this.getAttribute("data-style"));
			return false;
		});
		
		var c = readCookie('style');
		if (c) switchStylestyle(c);
							
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

function switchStylestyle(styleName)
	{
		$('link[@data-style*=style][title]').each(function(i) 
		{
			this.disabled = true;
			if (this.getAttribute('title') == styleName) this.disabled = false;
		});
		createCookie('style', styleName, 365);
	}

function createCookie(name,value,days){
	if (days)
	{
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		var expires = "; expires="+date.toGMTString();
	}
	else var expires = "";
	document.cookie = name+"="+value+expires+"; path=/";
}

function readCookie(name){
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++)
	{
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}

function eraseCookie(name){
	createCookie(name,"",-1);
}

function insert(text) {
    var textarea = document.getElementById("comment_content");
    if (textarea) {
        if (textarea.createTextRange && textarea.caretPos) { // IE
            var caretPos = textarea.caretPos;
            caretPos.text = caretPos.text.charAt(caretPos.text.length-1) == " " ? text+" " : text;
        } else if (textarea.setSelectionRange) { // Firefox
            var start = textarea.selectionStart,
                end = textarea.selectionEnd;
            textarea.value = textarea.value.substr(0,start)+text+textarea.value.substr(end);
            textarea.setSelectionRange(start+text.length, start+text.length);
        } else {
            textarea.value+=text+" ";
        }
        textarea.focus();
    }
}

window.onload=function(e)
{
		var match;
		if (match = /#i([0-9]+)/.exec(document.location.toString())) 
			$("[cols]").text(">>" + match[1]);
		if (match = /#([0-9]+)/.exec(document.location.toString())) 
			highlight("_" + match[1]);
}

function highlight(post) {
	    var cells = document.getElementsByTagName("table"),
	        reply = document.getElementById("reply"+post);
	    for (var i=0;i<cells.length;i++) {
	        if (cells[i].className == "highlight") {
	            cells[i].className = "reply";
	        }
	    }
	    if (reply) {
	        reply.className = "highlight";
	        return false;
	    }
	    return true;
}