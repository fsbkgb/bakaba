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