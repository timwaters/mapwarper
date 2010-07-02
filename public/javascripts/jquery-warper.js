jQuery.preloadImages = function(){ for(var i = 0; i<arguments.length; i++)
        { jQuery("<img>").attr("src", arguments[i]);  }
      }
jQuery.preloadImages("/images/spinner.gif");

function jqHighlight(element){
  jQuery("#"+element).effect('highlight',{}, 7000);
}

function bigModalDialog(message){
  jQuery("#noticeMessage").html(message);
  
  jQuery("#popoverNotice").dialog({
          bgiframe: true,
          height: 140,
          resizable: false,
          draggable: false,
          modal: true,
          hide: 'slow',
          title: 'Rectifier is Working...',
        //  close: function(){document.getElementById("warp_button").disabled = false; },
          zIndex: 1008
          });
  var warpButton = document.getElementById("warp_button");
  if (warpButton != null){
  warpButton.disabled = true;
  }
  jQuery("#popoverNotice").dialog('open');

}

function closeBigModalDialog(){
  jQuery("#popoverNotice").dialog('close');
 if( document.getElementById("warp_button")){;
 warpButton = document.getElementById("warp_button");
  warpButton.disabled = false;
 }

}

//duplicated functions because of ajax tabs and variable scope, below used by crop tool
function bigModalDialog2(message){
  jQuery("#noticeMessage2").html(message);
  
  jQuery("#popoverNotice2").dialog({
          bgiframe: true,
          height: 140,
          resizable: false,
          draggable: false,
          modal: true,
          hide: 'slow',
          title: 'Rectifier is Working...',
        //  close: function(){document.getElementById("warp_button").disabled = false; },
          zIndex: 1008
          });
  jQuery("#popoverNotice2").dialog('open');

}
function closeBigModalDialog2(){
  jQuery("#popoverNotice2").dialog('close');

}
