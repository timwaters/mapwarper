
function replaceMapTable(smaps){
  for (var a=0;a<smaps.length;a++){
    var smap = smaps[a];
    var tableRow = "<tr id='map-row-"+smap.id+"' class='minimap-tr'>"+
      "<td class='mini-map-thumb'><img src='"+mapThumbBaseURL+"/"+smap.id+"' height='70' ></td>"+
      "<td>"+smap.name + "<br />"+
      "<a href='"+mapBaseURL+"/"+smap.id+"' target='_blank'>Open layer</a> </td></tr>";

    jQuery("#searchmap-table").append(tableRow); 
  }
  addClickToTable();
}
function insertMapTablePagination(total, per, current){
  var num = current * per;
  var start = num - per;
  var last = false;
  var nextlot = current + 1;
  var prevlot = current - 1;
  if (total/per < current){
    num = total;
    last = true;
  }
  var tableCaption = "<caption>Found "+ total + " Layers. Showing "+ start +" - " +num  ;
  jQuery("#searchmap-table").append(tableCaption);


  var footer = "";
  var next = "<a href='#' onclick='do_search("+nextlot+"); return false;'>More<a/>";
  var previous = "";

  if (current > 1){
    previous  = "<a href='#' onclick='do_search("+prevlot+");'>Prev</a>&nbsp;&nbsp; "; 
  }
  if (last){
    next = "";
  }
  footer = "<tfoot><tr><td  colspan='2'>"+ previous + next +"</td></tr></tfoot>"; 

  jQuery("#searchmap-table").append(footer);
}


function addMapToMapLayer(mapitem){
  var layer = mapIndexLayer;
  var feature = new OpenLayers.Feature.Vector((
      new OpenLayers.Bounds.fromString(mapitem.bbox).transform(layer.map.displayProjection, layer.map.projection)).toGeometry());
  feature.mapTitle = mapitem.name; 
  feature.mapId = mapitem.id;
  layer.addFeatures([feature]);
}

function onFeatureSelect(feature) {
  selectedFeature = feature;
  popup = new OpenLayers.Popup.FramedCloud("cheese", 
    feature.geometry.getBounds().getCenterLonLat(),
    null,
    "<div class='searchmap-popup'><a href='" + mapBaseURL + "/"+ 
      feature.mapId + "' target='_blank'>"+
      //feature.mapTitle+"</a><br />"+
      "<a href='#a-map-row-"+feature.mapId+"' ><img title='"+feature.mapTitle+"' src='"+mapThumbBaseURL+"/"+feature.mapId+"' height='80'></a>"+
      "<br /> <a href='"+mapBaseURL+"/"+feature.mapId+"' target='_blank'>Open layer in new page.</a>"+
      "</div>",
    null, true, onPopupClose);
  popup.panMapIfOutOfView = false;
  popup.maxSize = new OpenLayers.Size(250,350);
  feature.popup = popup;
  searchmap.addPopup(popup);
  //jQuery("tr#map-row-"+feature.mapId).effect("highlight", {}, 4000);
  jQuery("tr#map-row-"+feature.mapId).addClass('highlight');
}


