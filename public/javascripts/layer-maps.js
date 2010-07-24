var layerMap;
var mapIndexLayer;
var mapIndexSelCtrl;
var selectedFeature;
function init(){
  OpenLayers.IMAGE_RELOAD_ATTEMPTS = 3;
  OpenLayers.Util.onImageLoadErrorColor = "transparent";

  var switcher = new OpenLayers.Control.LayerSwitcher(); 
  var options = {
    projection: new OpenLayers.Projection("EPSG:900913"),
    displayProjection: new OpenLayers.Projection("EPSG:4326"),
    units: "m",
    numZoomLevels:20,
    maxResolution: 156543.0339,
    maxExtent: new OpenLayers.Bounds(-20037508, -20037508,
      20037508, 20037508.34),
    controls: [
    new OpenLayers.Control.Attribution(),
    switcher,
    new OpenLayers.Control.Navigation(),
    new OpenLayers.Control.PanZoomBar()
    ]
  };

  layerMap = new OpenLayers.Map("map",options);
  mapnik_lay1 = mapnik.clone();

  layerMap.addLayers([mapnik_lay1]);

  wmslayer =  new OpenLayers.Layer.WMS
  ( "Layer"+layer_id,
    warpedwms_url,
    {format: 'image/png', layers: "image" },
    {         TRANSPARENT:'true', reproject: 'true'},
    { gutter: 15, buffer:0},
    { projection:"epsg:4326", units: "m"  }
  );
  wmslayer.setIsBaseLayer(false);
  wmslayer.visibility = true;
  layerMap.addLayer(wmslayer);
  
  bounds_merc = new OpenLayers.Bounds();
  bounds_merc = warped_bounds.transform(layerMap.displayProjection, layerMap.projection);
  
  layerMap.zoomToExtent(bounds_merc);
  layerMap.updateSize();
  
  layerMap.events.register("zoomend", mapnik_lay1, function(){
      if (this.map.getZoom() > 18 && this.visibility == true){
        this.map.setBaseLayer(nyc_lay1);
        switcher.maximizeControl();
      } 
    });
  
  //set up the map index layer to help find individual maps
  var mapIndexLayerStyle = OpenLayers.Util.extend({strokeWidth: 3}, OpenLayers.Feature.Vector.style['default']);
  var mapIndexSelectStyle = OpenLayers.Util.extend({}, OpenLayers.Feature.Vector.style['select']);
  var style_red = {
    fill: true,
    strokeColor: "#FF0000",
    strokeWidth: 3,
    fillOpacity: 0
  };
  var styleMap = new OpenLayers.StyleMap({
      'default': style_red,
      'select': mapIndexSelectStyle
    });
  
  mapIndexLayer = new OpenLayers.Layer.Vector("Map Outlines", {styleMap: styleMap, visibility: false});
  mapIndexSelCtrl = new OpenLayers.Control.SelectFeature(mapIndexLayer, {hover:false, onSelect: onFeatureSelect, onUnselect: onFeatureUnselect});
  layerMap.addControl(mapIndexSelCtrl);
  mapIndexSelCtrl.activate();
  layerMap.addLayer(mapIndexLayer);


  jQuery("#layer-slider").slider({
      value: 100,
      range: "min",
      slide: function(e, ui) {
        wmslayer.setOpacity(ui.value / 100);
        OpenLayers.Util.getElement('opacity').value = ui.value;
      }
    });

  loadMapFeatures();

  jQuery("#view-maps-index-link").append("(<a href='javascript:toggleMapIndexLayer();'>Toggle map outlines on map above</a>)");
}

function toggleMapIndexLayer(){
  var vis = mapIndexLayer.getVisibility();
  mapIndexLayer.setVisibility(!vis);
}

function loadMapFeatures(){
  var options = {'format': 'json'};
  OpenLayers.loadURL(mapLayersURL,
    options ,
    this,
    loadItems,
    failMessage);
}

function loadItems(resp){
  var g = new OpenLayers.Format.JSON();
  jobj = g.read(resp.responseText);
  lmaps = jobj.items;
  for (var a=0;a<lmaps.length;a++){
    var lmap = lmaps[a];
    addMapToMapLayer(lmap);
  }
}

function failMessage(resp){
  alert("Sorry, something went wrong loading the items");
}

function addMapToMapLayer(mapitem){
  var feature = new OpenLayers.Feature.Vector((
      new OpenLayers.Bounds.fromString(mapitem.bbox).transform(layerMap.displayProjection, layerMap.projection)).toGeometry());
  feature.mapTitle = mapitem.title; 
  feature.mapId = mapitem.id;
  mapIndexLayer.addFeatures([feature]);
}

function onPopupClose(evt) {
  mapIndexSelCtrl.unselect(selectedFeature);
}
function onFeatureSelect(feature) {
  selectedFeature = feature;
  popup = new OpenLayers.Popup.FramedCloud("amber_lamps", 
    feature.geometry.getBounds().getCenterLonLat(),
    null,
    "<div class='layermap-popup'> Map "+
      feature.mapId + "<br /> <a href='" + mapBaseURL + "/"+ feature.mapId + "' target='_blank'>"+feature.mapTitle+"</a><br />"+
      "<img src='"+mapThumbBaseURL+feature.mapId+"' height='80'>"+
      "<br /> <a href='"+mapBaseURL+"/"+feature.mapId+"#Rectify_tab' target='_blank'>Edit this map</a>"+
      "</div>",
    null, true, onPopupClose);
  popup.minSize = new OpenLayers.Size(180,150);
  feature.popup = popup;
  layerMap.addPopup(popup);
}

function onFeatureUnselect(feature) {
  layerMap.removePopup(feature.popup);
  feature.popup.destroy();
  feature.popup = null;
}  
