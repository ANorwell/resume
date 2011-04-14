$(function() {
		$( ".elt-set" ).sortable();
        $("#exp-button").button().click(makeNewElt);
	});


var node_counter = 0;


//A node represents the info of an entry.
//The list of nodes is probably inferred
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
