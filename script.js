$(function() {
		$( ".elt-set" ).sortable();
        $("#exp-button").button().click(makeNewElt);
	});


var node_counter = 0;


//A node represents the info of an entry.
function Node() {
    this.id  = "Node" + node_counter;
    node_counter += 1;
    this.input = {
    Company : "",
    Title : "",
    Date: "",
    Location: "",
    URL: "",
    };
};

Node.prototype.toHtmlElt = function(parent) {
    var node = $("<div></div>").addClass("elt").attr('id', this.id);

    node.append( $("<div>Position</div>").addClass("elt-header") );
    var content = $("<div></div>").addClass("elt-content");
    node.append(content);

    for (i in this.input) {
        var id = 'exp-' + i + this.id;
        content.append(
            $("<div>" +
              "<label class='elt-label' for='" + id + "'>" +
              i +
              "</label>" +
              "<input id='" + id + "'></input>" +
              "</div>") );
    }

    node.addClass( "ui-widget ui-widget-content ui-helper-clearfix ui-corner-all" )
    .find( ".elt-header" )
    .addClass( "ui-widget-header ui-corner-all" )
    .prepend( "<span class='ui-icon ui-icon-minusthick'></span>")
    .end()
    .find( ".elt-content" );
    
    node.find(".elt-header .ui-icon" ).click(function() {
            $( this ).toggleClass( "ui-icon-minusthick" ).toggleClass( "ui-icon-plusthick" );
            $( this ).parents( ".elt:first" ).find( ".elt-content" ).toggle();
        });

    parent.append(node);

};

    
    
function makeNewElt() {
    var n = new Node();
    n.toHtmlElt( $("#exp-list") );
}


/////////////////////
// FB stuff
///////////////////////////

//These variables are populated in a script tag from php
window.fbAsyncInit = function() {
    FB.init({
        appId   : APP_ID,
                session : SESSION_JSON, // don't refetch the session when PHP already has it
                status  : true, // check login status
                cookie  : true, // enable cookies to allow the server to access the session
                xfbml   : true // parse XFBML
                });

    // whenever the user logs in, we refresh the page
    FB.Event.subscribe('auth.login', function() {
            window.location.reload();
        });
};

/*
(function() {
    var e = document.createElement('script');
    e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
    e.async = true;
    $('#fb-root').append(e);


}());
*/
