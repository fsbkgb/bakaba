jQuery(document).ready(function($) {
    $('.lightbox_trigger').click(function(e) {
        //prevent default action (hyperlink)
        e.preventDefault();
        //Get clicked link href
        var image_href = $(this).attr("href");
        /*
        If the lightbox window HTML already exists in document,
        change the img src to to match the href of whatever link was clicked
        If the lightbox window HTML doesn't exists, create it and insert it.
        (This will only happen the first time around)
        */
        if ($('#lightbox').length > 0) { // #lightbox exists
            //place href as img src value
            $('#lightbox_content').html('<img src="' + image_href + '" />');
            //show lightbox window - you could use .show('fast') for a transition
            $('#lightbox').fadeIn(100);
        }
        else { //#lightbox does not exist - create and insert (runs 1st time only)
            //create HTML markup for lightbox window
            var lightbox =
            '<div id="lightbox">' +
                '<div id="lightbox_content">' + //insert clicked link's href into img src
                    '<img src="' + image_href +'" />' +
                '</div>' +
            '</div>';
            //insert lightbox HTML into page
            $('body').append(lightbox);
            //Click anywhere on the page to get rid of lightbox window
            $("#lightbox").click(function() { //must use live, as the lightbox element is inserted into the DOM
               $('#lightbox').fadeOut(150);
            });
        }
    });
});