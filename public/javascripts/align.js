var gridArray = new Array();
var currentPlaceholder;

var map = jQuery("#mapid");

jQuery(function() {

    place = new Object;
    place.place = "place_4";
    place.map = map_id;
    gridArray.push( place );
    addImageTo(place.place, map_id);

    jQuery("#sortable").sortable({
        placeholder: 'ui-state-highlight',
        cancel: '.ui-state-disabled'
    });

    jQuery("#sortable").disableSelection();

    jQuery("a.add_map").click(function(e){
        currentPlaceholder = e.target.parentNode.id;
        jQuery('#dialog').dialog('open');
        return false;
    })
    .hover(
        function(){
            jQuery(this).addClass("ui-state-hover");
        },
        function(){
            jQuery(this).removeClass("ui-state-hover");
        }
        ).mousedown(function(){
        jQuery(this).addClass("ui-state-active");
    })
    .mouseup(function(){
        jQuery(this).removeClass("ui-state-active");
    });

    jQuery("#align-accordian").accordion({
        autoHeight: false,
        collapsible: true
    });
    jQuery("#align-accordian button").click(function(evt){
        jQuery("#mapid").val(evt.target.id);
        jQuery("#dialog").dialog("option","buttons")["Add Map"].apply(jQuery("#dialog"));
    });


    jQuery("#dialog").dialog({
        bgiframe: true,
        autoOpen: false,
        height: 500,
        width: 600,
        modal: true,
        buttons: {
            'Add Map': function() {
                var maptoadd = jQuery("#mapid").val();
                jQuery("a.add_map").hide();
                place = new Object;
                place.place = currentPlaceholder;
                place.map = maptoadd;
                gridArray.push( place );
                addImageTo(currentPlaceholder, maptoadd);
                jQuery(this).dialog('close');
                jQuery("#srcmap").val(maptoadd);
            },
            Cancel: function() {
                jQuery(this).dialog('close');
            }
        },
        close: function() {
        }
    });
});



function serialiseStuff(){

    frm = document.getElementById('align_form');

    finalPos = jQuery("#sortable").sortable("toArray");

    if (gridArray.length <= 1){
        alert("Sorry, but there should be at least two maps selected");
        return false;
    }
    origSrc = gridArray[0].place.substring(gridArray[0].place.length-1); //i.e. 2
    origDst = gridArray[1].place.substring(gridArray[1].place.length-1);
    finalSrc = jQuery.inArray("place_"+(origSrc-0),finalPos)+1;
    finalDst = jQuery.inArray("place_"+(origDst-0),finalPos)+1;

    var diff = finalSrc - finalDst;
    if ((finalSrc == 2 && finalDst == 3) || (finalSrc == 3 && finalDst == 2)){
        diff = 4; //diagonal
    }

    switch(diff) {
        case -1:
            align = "east";
            break;
        case 1:
            align = "west";
            break;
        case 2:
            align = "north";
            break;
        case -2:
            align = "south";
            break;
        default:
            align = "other";
    }

    if (align == "other") {
        alert("Sorry, only horizontal and vertical alignment are available at the moment");
        return false;

    }else {

        document.getElementById("align").value = align;

        if ((frm.destmap.value != frm.srcmap.value) && (frm.destmap.value.length > 0)){
            return true;
        }else {
            alert("Sorry, either no map was selected, or the same map number was entered");
            return false;
        }
    }


}

