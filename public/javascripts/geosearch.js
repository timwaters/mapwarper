/* geosearch.js core generic functions for helping to search for maps
 * or layers using a map
 * see geosearch-map.js and geosearch-layer.js
 * which implements
 * the following functions:
 * replaceMapTable(maps)
 * insertMapTablePagination(total, per, current)
 * addMapToMapLayer(mapitem)
 * onFeatureSelect(feature)
 **/


var searchmap;
var maxOpacity = 1;
var minOpacity = 0.1;
var mapIndexLayer;
var mapIndexSelCtrl;
var selectedFeature;
var firstGo = true;
function searchmapinit(){
  jQuery('#loadingDiv').hide();
  
  OpenLayers.IMAGE_RELOAD_ATTEMPTS = 3;
  OpenLayers.Util.onImageLoadErrorColor = "transparent";
  var options_warped = {
    projection: new OpenLayers.Projection("EPSG:900913"),
    displayProjection: new OpenLayers.Projection("EPSG:4326"),
    units: "m",
    numZoomLevels:20,
    maxResolution: 156543.0339,
    maxExtent: new OpenLayers.Bounds(-20037508, -20037508,
      20037508, 20037508),
    controls: [
    new OpenLayers.Control.Attribution(),
    new OpenLayers.Control.LayerSwitcher(),
    new OpenLayers.Control.Navigation(),
    new OpenLayers.Control.PanZoomBar()
    ]
  };

  searchmap = new OpenLayers.Map('searchmap', options_warped);
  // create OSM layer
  mapnik_s = mapnik.clone();
  searchmap.addLayer(mapnik_s);

  //set up the map index layer to help find individual maps
    var mapIndexLayerStyle = OpenLayers.Util.extend({
        strokeWidth: 3
    }, OpenLayers.Feature.Vector.style['default']);
    var mapIndexSelectStyle = OpenLayers.Util.extend({
        fillColor: "#ee9900",
        fillOpacity: 0.4
    }, OpenLayers.Feature.Vector.style['select']);

    var no_style = {
        fill: false,
        fillOpacity: 0.0
    };

    var style_blue = {
        fill: true,
        strokeOpacity: 1,
        strokeColor: "#blue",
        fillColor: "blue",
        fillOpacity: 0.4,
        strokeWidth: 2
    };
  
    var styleMap = new OpenLayers.StyleMap({
        'default': no_style,
        'select': style_blue
    });

  mapIndexLayer = new OpenLayers.Layer.Vector("Map Outlines", {styleMap: styleMap, visibility: false});
  mapIndexSelCtrl = new OpenLayers.Control.SelectFeatureNoClick(mapIndexLayer, {hover:false, onSelect: onFeatureSelect, onUnselect: onFeatureUnselect});
  searchmap.addControl(mapIndexSelCtrl);
  mapIndexSelCtrl.deactivate(); 

  searchmap.addLayer(mapIndexLayer);
  searchmap.events.register("moveend", this, updateSearch); 

  clipmap_bounds_merc  = new OpenLayers.Bounds();
  clipmap_bounds_merc = gs_bounds.transform(searchmap.displayProjection, searchmap.projection);

  searchmap.zoomToExtent(clipmap_bounds_merc, true);

 
  addClickToTable();
  do_search();
}

var currentState;
function updateSearch(){
  var currentTime = (new Date()).valueOf();

  currentState = {tag: currentTime};
  if (!firstGo){
    setTimeout(function() {updateStuff(currentTime); }, 2000);
  } else {
    firstGo = false;
  }
}

function updateStuff(expectedTag){
  if (currentState.tag != expectedTag) {
    return;
  }else {
    do_search();
  }
}

function addClickToTable(){
  jQuery("#searchmap-table tr").click(function(){
      removeAllPopups(searchmap);
      mapIndexSelCtrl.unselectAll();
      var mapid = this.id.substring("map-row-".length);
      var feat;
      for (var a=0;a<mapIndexLayer.features.length;a++){
        if (mapIndexLayer.features[a].mapId == mapid){
         feat = mapIndexLayer.features[a];
        }
      }
      //highlight map polygon
      mapIndexSelCtrl.select(feat);
    }
  );
}



function doPlaceSearch(frm){
  var place = frm.place.value;
  var options = { 
    'place': place,
    'format': 'json'
  };

  OpenLayers.loadURL(mapBaseURL+'/geosearch',
    options,
    this,
    doPlaceZoom,
    failMessage);
}

function doPlaceZoom(resp){
  var js = new OpenLayers.Format.JSON();
  extent = js.read(resp.responseText);
  var newext = new OpenLayers.Bounds(extent[0],extent[1],extent[2],extent[3]);
  var mercExtent = newext.transform(searchmap.displayProjection, searchmap.projection);
  searchmap.zoomToExtent(mercExtent);
}

  function do_search(pageNum){
  jQuery('#loadingDiv').show();
  
  if (typeof pageNum == "undefined"){
      pageNum = 1;
    }
  var searchmapExtent =  searchmap.getExtent().transform(searchmap.projection, searchmap.displayProjection).toArray();
  var options = {'bbox': searchmapExtent,
    'format': 'json',
    'page': pageNum,
    'operation': 'intersect'};
  OpenLayers.loadURL(mapBaseURL+'/geosearch',
    options,
    this,
    loadItems,
    failMessage);
}
function clearMapTable(){
  jQuery("#searchmap-table").empty();
  
}
function loadItems(resp){
    clearMapTable();
    removeAllPopups(searchmap);
 
    mapIndexLayer.destroyFeatures();
    var j = new OpenLayers.Format.JSON();
    jj = j.read(resp.responseText);
    smaps = jj.items;
    for (var a=0;a<smaps.length;a++){
      var smap = smaps[a];
      addMapToMapLayer(smap);
    }
    insertMapTablePagination(jj.total_entries, jj.per_page, jj.current_page);
    replaceMapTable(smaps);
    mapIndexLayer.setVisibility(true);

    jQuery('#loadingDiv').hide();
  }

function failMessage(resp){
  alert("Sorry, something went wrong with the search");
  jQuery('#loadingDiv').hide();
}

function onPopupClose(evt) {
  mapIndexSelCtrl.unselect(selectedFeature);
}

function onFeatureUnselect(feature) {
  jQuery("tr#map-row-"+feature.mapId).removeClass('highlight');
  searchmap.removePopup(feature.popup);
  feature.popup.destroy();
  feature.popup = null;
} 

function removeAllPopups(map){
  for (var i=0; i<map.popups.length; i++) {
    map.removePopup(map.popups[i]);
  }
}


