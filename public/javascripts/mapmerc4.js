var temp_gcp_status = false;
var from_templl;
var to_templl;
var warped_layer; //the warped wms layer
var to_layer_switcher;
var navig;
var navigFrom;
var to_vectors;
var from_vectors;
var active_to_vectors;
var active_from_vectors;

///////////////////////////////////////////////////////////////////////////////////////////
//
// INIT
//
///////////////////////////////////////////////////////////////////////////////////////////
function init() {

    from_map = new OpenLayers.Map('from_map', {
        controls: [ new OpenLayers.Control.PanZoomBar()],
        maxExtent: new OpenLayers.Bounds(0, 0, image_width, image_height),
        maxResolution: 'auto',
        numZoomLevels: 20
    });
  //  from_map.addControl(new OpenLayers.Control.MousePosition());

    var image = new OpenLayers.Layer.WMS( title,
        wms_url, {
        format: 'image/png',
        status: 'unwarped'},
        {
        transitionEffect: 'resize'
        } );

    from_map.addLayer(image);

    if (!from_map.getCenter()){
      from_map.zoomToMaxExtent();
    }

    OpenLayers.IMAGE_RELOAD_ATTEMPTS = 3;
    OpenLayers.Util.onImageLoadErrorColor = "transparent";

    to_layer_switcher = new OpenLayers.Control.LayerSwitcher();
    var options = {
        projection: new OpenLayers.Projection("EPSG:900913"),
        displayProjection: new OpenLayers.Projection("EPSG:4326"),
        units: "m",
        numZoomLevels: 20,
        maxResolution: 156543.0339,
        maxExtent: new OpenLayers.Bounds( - 20037508, -20037508, 20037508, 20037508.34),
        controls: [ new OpenLayers.Control.Attribution(), to_layer_switcher, new OpenLayers.Control.PanZoomBar()]
    };

    to_map = new OpenLayers.Map('to_map', options);

     warped_layer = new OpenLayers.Layer.WMS.Untiled("warped map", wms_url, {
        format: 'image/png',
        status: 'warped'  },
    {   TRANSPARENT: 'true', reproject: 'true'},
    {   gutter: 15, buffer: 0},
    {   projection: "epsg:4326",  units: "m"}
    );


    var warpedOpacity = 0.6;
    warped_layer.setOpacity(warpedOpacity);
    warped_layer.setVisibility(false);
    warped_layer.setIsBaseLayer(false);
    to_map.addLayer(warped_layer);

    to_map.addLayer(mapnik);


    for (var i =0; i < layers_array.length;i++){
      to_map.addLayer(get_map_layer(layers_array[i]));
    }


    jpl_wms.setVisibility(false);
    to_map.addLayer(jpl_wms);

    if (map_has_bounds) {
      map_bounds_merc = new OpenLayers.Bounds();
      map_bounds_merc  = lonLatToMercatorBounds(map_bounds);

      to_map.zoomToExtent(map_bounds_merc);

    } else {
      //set to the world
        to_map.setCenter(lonLatToMercator(new OpenLayers.LonLat(0.0, 0.0)), 10);
    }

    //style for the active, temporary vector marker, the one the user actually adds themselves,
    var active_style = OpenLayers.Util.extend({},
        OpenLayers.Feature.Vector.style['default']);
    active_style.graphicOpacity = 1;
    active_style.graphicWidth = 14;
    active_style.graphicHeight = 22;
    active_style.graphicXOffset = - (active_style.graphicWidth/2);
    active_style.graphicYOffset = - active_style.graphicHeight;
    active_style.externalGraphic = icon_imgPath + "AQUA.png";

    to_vectors = new OpenLayers.Layer.Vector("To vector markers");
    to_vectors.displayInLayerSwitcher = false;

    from_vectors = new OpenLayers.Layer.Vector("From vector markers");
    from_vectors.displayInLayerSwitcher = false;

    active_to_vectors = new OpenLayers.Layer.Vector("active To vector markers", {style: active_style});
    active_to_vectors.displayInLayerSwitcher = false;

    active_from_vectors = new OpenLayers.Layer.Vector("active from vector markers", {style: active_style});
    active_from_vectors.displayInLayerSwitcher = false;

    to_map.addLayers([to_vectors,active_to_vectors]);
    from_map.addLayers([from_vectors, active_from_vectors]);
    //fix for dragging bug
  //  OpenLayers.Control.DragFeature.prototype.upFeature = function() {};
    //fix
    var to_panel = new OpenLayers.Control.Panel (
        {displayClass: 'olControlEditingToolbar'}
        );
    var dragMarker = new OpenLayers.Control.DragFeature(to_vectors,
        {displayClass: 'olControlDragFeature', title:'Move Control Point'});
    dragMarker.onComplete = function(feature) {
      saveDraggedMarker(feature);
    };

    var drawFeatureTo = new OpenLayers.Control.DrawFeature(active_to_vectors, OpenLayers.Handler.Point ,
        {displayClass: 'olControlDrawFeaturePoint', title: 'Add Control Point', handlerOptions: {style: active_style}});
    drawFeatureTo.featureAdded = function(feature) {
      newaddGCPto(feature);
    };

    var drawFeatureFrom = new OpenLayers.Control.DrawFeature(active_from_vectors, OpenLayers.Handler.Point ,
        {displayClass: 'olControlDrawFeaturePoint', title: 'Add Control Point', handlerOptions: {style: active_style}});
    drawFeatureFrom.featureAdded = function(feature) {
      newaddGCPfrom(feature);
    };

    var from_panel = new OpenLayers.Control.Panel (
        {displayClass: 'olControlEditingToolbar'}
        );
    var dragMarkerFrom = new OpenLayers.Control.DragFeature(from_vectors,
        {displayClass: 'olControlDragFeature', title:'Move Control Point'});
    dragMarkerFrom.onComplete = function(feature) {
      saveDraggedMarker(feature);
    };

    navig = new OpenLayers.Control.Navigation({title: "Move Around Map"});
    navigFrom = new OpenLayers.Control.Navigation({title: "Move Around Map"});

    to_panel.addControls([navig, dragMarker, drawFeatureTo]);
    to_map.addControl(to_panel);

    from_panel.addControls([navigFrom, dragMarkerFrom, drawFeatureFrom]);
    from_map.addControl(from_panel);

    //we'll add generic navigation controls so we can zoom whilst addingd
    to_map.addControl(new OpenLayers.Control.Navigation());
    from_map.addControl(new OpenLayers.Control.Navigation());

    navig.activate();
    navigFrom.activate();

    joinControls(dragMarker, dragMarkerFrom);
    joinControls(navig, navigFrom);
    joinControls(drawFeatureTo, drawFeatureFrom);


      //set up jquery slider for warped layer
      jQuery("#warped-slider").slider({
          value: 100 * warpedOpacity,
          range: "min",
          slide: function(e, ui) {
            warped_layer.setOpacity(ui.value / 100);
          }
        });
      jQuery("#warped-slider").hide();
      warped_layer.events.register('visibilitychanged', this, function(layer){
          if (layer.object.getVisibility() === true){
            jQuery("#warped-slider").show();
          } else {
            jQuery("#warped-slider").hide();
          }
    });


    }

function joinControls(first, second){
  first.events.register("activate", first, function(){second.activate();});
  first.events.register("deactivate", first, function(){second.deactivate();});
  second.events.register("activate", second, function(){first.activate();});
  second.events.register("deactivate", second, function(){first.deactivate();});
}

function get_map_layer(layerid){
var newlayer_url = layer_baseurl + "/"+layerid;
var map_layer =  new OpenLayers.Layer.WMS
     ( "Layer "+ layerid,
       newlayer_url,
       {format: 'image/png'},
       {TRANSPARENT:'true', reproject: 'true'},
       { gutter: 15, buffer:0},
       { projection:"epsg:4326", units: "m"  }
     );
map_layer.setIsBaseLayer(false);
map_layer.visibility = false;

return map_layer;
}


var moving = false;
var origXYZ = new Object();

function moveStart(mapEvent){
  var passiveMap;
  var activeMap;
  if (this == 1) {
    activeMap = from_map;
    passiveMap = to_map;
  }else{
    activeMap = to_map;
    passiveMap = from_map;
  }
  var cent = activeMap.getCenter();
  origXYZ.lonlat = cent;
  origXYZ.zoom = activeMap.zoom;
}


function moveEnd(mapEvent){
if (moving){
  return;
}
  moving = true;
  var passiveMap;
  var activeMap;
  if (this == 1) {
    activeMap = from_map;
    passiveMap = to_map;
  }else{
    activeMap = to_map;
    passiveMap = from_map;
  }
  var newZoom = passiveMap.zoom;
  if (origXYZ.zoom != activeMap.zoom){
    diffzoom = origXYZ.zoom - activeMap.zoom;
    newZoom = passiveMap.zoom - diffzoom;
  }
  var origPixel = activeMap.getPixelFromLonLat(origXYZ.lonlat);
  var newPixel = activeMap.getPixelFromLonLat(activeMap.getCenter());
  var difx = origPixel.x - newPixel.x;
  var dify = origPixel.y - newPixel.y;
  var passCen = passiveMap.getPixelFromLonLat(passiveMap.getCenter());
  passiveMap.setCenter(passiveMap.getLonLatFromPixel(
        new OpenLayers.Pixel(passCen.x - difx, passCen.y - dify)), newZoom, false, false);

 moving = false;

}
var mapLinked = false;
function toggleJoinLinks(){
  //TODO change the icon
    if (mapLinked === true){
    mapLinked = false;
    document.getElementById('link-map-button').className = 'link-map-button-off';
  }  else {
       mapLinked = true;
       document.getElementById('link-map-button').className = 'link-map-button-on';
 }
  if(mapLinked === true){
    from_map.events.register("moveend",1, moveEnd);
    to_map.events.register("moveend",0, moveEnd);
    from_map.events.register("movestart",1, moveStart);
    to_map.events.register("movestart",0, moveStart);
  }else {
    from_map.events.unregister("moveend",1,moveEnd);
    to_map.events.unregister("moveend", 0, moveEnd);
    from_map.events.unregister("movestart", 1, moveStart);
    to_map.events.unregister("movestart", 0, moveStart);
        }
}

function gcp_notice(text){
  //jquery effect
  jqHighlight('rectifyNotice');
  notice = document.getElementById('gcp_notice');
  notice.innerHTML = text;
}

function update_gcp_field(gcp_id, elem) {
    var id = gcp_id;
    var value = elem.value;
    var attrib = elem.id.substring(0, (elem.id.length - (id+"").length));
    var url = gcp_update_field_url + "/" + id;

    Element.show('spinner');
    gcp_notice('Updating...');

    var options = {
        method: "put",
        parameters: 'authenticity_token=' + encodeURIComponent(window._token) + "&attribute=" + attrib + "&value=" + value,
        asynchronous: true,
        onSuccess: function(transport) {
          gcp_notice("Control Point updated!");
          move_map_markers(gcp_id, elem);
                     },
        onFailure: function(transport) {
          gcp_notice("Had trouble updating that point with the server. Try again?");
          elem.value = value; },
        onComplete: function(transport) {Element.hide('spinner');},
        evalScripts: true };

  request = new Ajax.Request(url, options);
}

function update_gcp(gcp_id, listele) {
  var id = gcp_id;
  var url = gcp_update_url + "/" + id;

  for (i=0;i<listele.childNodes.length; i++){
    listtd = listele.childNodes[i]; //td
    for (e=0;e<listtd.childNodes.length; e++){

      listItem = listtd.childNodes[e];//input
      if (listItem.id == "x"+gcp_id) {x = listItem.value;}
      if (listItem.id == "y"+gcp_id) {y = listItem.value;}
      if (listItem.id == "lon"+gcp_id) {lon = listItem.value;}
      if (listItem.id == "lat"+gcp_id) {lat = listItem.value;}

    }
  }
  gcp_notice('Updating...');
  Element.show('spinner');
   var options = {
        method: "put",
        parameters: 'authenticity_token=' + encodeURIComponent(window._token) + "&x="+x+"&y="+y+"&lon="+lon+"&lat="+lat,
        asynchronous: true,
        onSuccess: function(transport) {
          gcp_notice("Control Point updated");
          },
        onFailure: function(transport) {
          gcp_notice("Had trouble updating that point with the server. Try again?");
           },
        onComplete: function(transport) {Element.hide('spinner');},
        evalScripts: true };

  request = new Ajax.Request(url, options);

}

function move_map_markers(gcp_id, elem){
  var avalue = elem.value;
  var attrib = elem.id;
  trele = elem.parentNode.parentNode; //input>td>tr
  //get the other siblings next door to this one.
  for (i=0;i<trele.childNodes.length; i++){
    trchild = trele.childNodes[i]; //tds
    for (e=0;e<trchild.childNodes.length; e++){

      inp = trchild.childNodes[e]; //inputs
      if (inp.id == 'x'+gcp_id){ x = inp.value;}
      if (inp.id == 'y'+gcp_id){ y = image_height - inp.value ;}
      if (inp.id == 'lon'+gcp_id){ tlon = inp.value;}
      if (inp.id == 'lat'+gcp_id) {tlat = inp.value;}
    }
  }

  if (attrib == 'x'+gcp_id || attrib == 'y'+gcp_id) {
    var frommark;
    for (var a = 0; a < from_vectors.features.length; a++) {
      if (from_vectors.features[a].gcp_id == gcp_id) {
        frommark = from_vectors.features[a];
      }//if
    } //for
    if (attrib == 'x'+gcp_id) {x = avalue;}
    if (attrib == 'y'+gcp_id) {y = image_height - avalue;}
    //frommark.geometry.move(new OpenLayers.LonLat(x, y));
    frommark.geometry.x = x;
    frommark.geometry.y = y;
    frommark.geometry.clearBounds();
    frommark.layer.drawFeature(frommark);
  }

  else if (attrib == 'lon'+gcp_id || attrib == 'lat'+gcp_id)  {
    var tomark;
    for (var b = 0; b < to_vectors.features.length; b++) {
      if (to_vectors.features[b].gcp_id == gcp_id) {
         tomark = to_vectors.features[b];
      } //if
    }//for
    if (attrib == 'lon'+gcp_id) {tlon = avalue;}
    if (attrib == 'lat'+gcp_id) {tlat = avalue;}

    hacklonlat = lonLatToMercator(new OpenLayers.LonLat(tlon, tlat));
    tomark.geometry.x = hacklonlat.lon;
    tomark.geometry.y = hacklonlat.lat;
    tomark.geometry.clearBounds();
    tomark.layer.drawFeature(tomark);
  }
}

//when a vector marker is dragged, update values on form and save
function saveDraggedMarker(feature){

  var listele = document.getElementById("gcp"+feature.gcp_id); //listele is a tr
  for (i=0;i<listele.childNodes.length; i++){
    listtd = listele.childNodes[i];//listtd is a td

    for (e=0;e<listtd.childNodes.length; e++){
      listItem = listtd.childNodes[e]; //listitem is the input field

      if (feature.layer == from_vectors){
        if (listItem.id == "x"+feature.gcp_id) { listItem.value = feature.geometry.x;}
        if (listItem.id == "y"+feature.gcp_id) { listItem.value = image_height - feature.geometry.y;}
      }
      if (feature.layer == to_vectors){
        var merc = new OpenLayers.LonLat(feature.geometry.x,feature.geometry.y);
        var vll = mercatorToLonLat(merc);
        if (listItem.id == "lon"+feature.gcp_id) { listItem.value = vll.lon;}
        if (listItem.id == "lat"+feature.gcp_id) { listItem.value = vll.lat;}
      }
    }//for
  }//for
  update_gcp(feature.gcp_id, listele);
}

function save_new_gcp(x, y, lon, lat) {

    url = gcp_add_url;
    gcp_notice("Adding...");
    Element.show('spinner');

    var options = {

        asynchronous: true,
        evalScripts: true,
        method: "post",
        parameters: 'authenticity_token=' + encodeURIComponent(window._token) + "&x=" + x + "&y=" + y + "&lat=" + lat + "&lon=" + lon,
        onComplete: function(transport){
          update_row_numbers();
          Element.hide('spinner');
        },
        onFailure: function(transport) {gcp_notice("Had trouble saving that point to the server. Try again?");},
        onSuccess: function() {      }
    };
    request = new Ajax.Request(url, options);
}


function update_rms(new_rms){
fi = document.getElementById('errortitle');
fi.value = "Error("+new_rms +")";
}


function delete_markers(gcp_id) {
    for (var a = 0; a < from_vectors.features.length; a++) {

        if (from_vectors.features[a].gcp_id == gcp_id) {

            del_from_mark = from_vectors.features[a];
            del_to_mark = to_vectors.features[a];

            from_vectors.destroyFeatures([del_from_mark]);
            to_vectors.destroyFeatures([del_to_mark]);
        }
    }
update_row_numbers();
}


//called after initial populate, each delete, and each add
function update_row_numbers(){
  for (var a = 0; a < from_vectors.features.length; a++) {
    temp_marker = from_vectors.features[a];
    li_ele = document.getElementById("gcp"+temp_marker.gcp_id);

    ////////////////
    inputs = li_ele.getElementsByTagName("input");
    for (var b=0;b<inputs.length;b++) {
      if (inputs[b].name == "error"+temp_marker.gcp_id) {
        error = inputs[b].value;
      }
    }
    var color = getColorString(error);
    updateGcpColor(from_vectors.features[a], color);
    updateGcpColor(to_vectors.features[a], color);
    ////////////

    span_ele = li_ele.getElementsByTagName("span");
    if (span_ele[0].className == "marker_number"){
      var thishtml = "<img src='"+icon_imgPath+(temp_marker.id_index + 1) + color + ".png' />";
      //var thishtml = "<img src='../../images/icons/"+(temp_marker.id_index + 1) + ".png' />";
      span_ele[0].innerHTML = thishtml;
    }
  }
redrawGcpLayers();
}



function redrawGcpLayers(){
  from_vectors.redraw();
  to_vectors.redraw();
}


function updateGcpColor(marker, color){
    marker.style.externalGraphic = icon_imgPath+(marker.id_index + 1) + color + '.png';
}



//blue, green, orange, red
function getColorString(error){
  var colorString = "";
  if (error < 5){
    colorString = "";
  }else if(error >= 5 && error < 10){
    colorString = "_green";
  }else if(error >=10 && error <50){
    colorString = "_orange";
  }else if(error >=50){
    colorString = "_red";
  }
  //TODO
  return colorString;
  //return "";
}


function populate_gcps(gcp_id, img_lon, img_lat, dest_lon, dest_lat, error) {
  error = typeof(error) != "undefined" ? error : 0;
  var color = getColorString(error);

  //x y lon lat
  index = gcp_markers.length;
  gcp_markers.push(index); // 0 to 7 or so
  got_lon = img_lon;
  got_lat = image_height - img_lat;
  add_gcp_marker(from_vectors, new OpenLayers.LonLat(got_lon, got_lat), false, index, gcp_id, color);

  add_gcp_marker(to_vectors, lonLatToMercator(new OpenLayers.LonLat(dest_lon, dest_lat)), false, index, gcp_id, color);
}


function set_gcp() {
  check_if_gcp_ready();
    if (!temp_gcp_status ) {
      alert("You have to add a new control point on each map before pressing this button.");
      return false;
    } else {
        var from_lonlat = from_templl;
        var to_lonlat = mercatorToLonLat(to_templl);

        var img_lon = from_lonlat.lon;
        var img_lat = from_lonlat.lat;

        var proper_img_lat = image_height - img_lat;
        var proper_img_lon = img_lon;

        save_new_gcp(proper_img_lon, proper_img_lat, to_lonlat.lon, to_lonlat.lat);

        active_from_vectors.destroyFeatures();
        active_to_vectors.destroyFeatures();
    }
}



function add_gcp_marker(markers_layer, lonlat, is_active_marker, id_index, gcp_id, color) {
  color = typeof(color) != "undefined" ? color : "";
  id_index = typeof(id_index) != 'undefined' ? id_index: -2;
  var style_mark = OpenLayers.Util.extend({},
      OpenLayers.Feature.Vector.style['default']);
  style_mark.graphicOpacity = 1;
  style_mark.graphicWidth = 14;
  style_mark.graphicHeight = 22;
  style_mark.graphicXOffset = -(style_mark.graphicWidth/2);
  style_mark.graphicYOffset = -style_mark.graphicHeight;
  if (is_active_marker === true){
    active_style.externalGraphic = icon_imgPath+"AQUA.png";
  } else {
    style_mark.externalGraphic = icon_imgPath+(id_index + 1) + color + '.png';
  }
  var thisVector = new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat);
  var pointFeature = new OpenLayers.Feature.Vector(thisVector, null, style_mark);
  pointFeature.id_index = id_index;
  pointFeature.gcp_id = gcp_id;

  markers_layer.addFeatures([pointFeature]);

  resetHighlighting();
}



function addLayerToDest(frm){
  num =frm.layer_num.value;
  new_wms_url = empty_wms_url+'/'+num;

   new_warped_layer = new OpenLayers.Layer.WMS.Untiled("warped map "+num, new_wms_url, {
        format: 'image/png',
        status: 'warped'
    },
    {
        TRANSPARENT: 'true',
        reproject: 'true'
    },
    {
        gutter: 15,
        buffer: 0
    },
    {
        projection: "epsg:4326",
        units: "m"
    });
    new_warped_layer.setOpacity(0.6);
    new_warped_layer.setVisibility(true);
    new_warped_layer.setIsBaseLayer(false);
    to_map.addLayer(new_warped_layer);

    to_layer_switcher.maximizeControl();

  Element.hide('add_layer');

}

function show_warped_map(){
  warped_layer.setVisibility(true);
  warped_layer.mergeNewParams({'random':Math.random()});
  warped_layer.redraw(true);
  to_layer_switcher.maximizeControl();

  //cross tab issue - reloads the rectified map in the preview tab if its there
  if (typeof warpedmap != 'undefined' && typeof warped_wmslayer != 'undefined'){
    warped_wmslayer.mergeNewParams({'random':Math.random()});
    warped_wmslayer.redraw(true);
  }
}


function check_if_gcp_ready() {
    if (active_to_vectors.features.length > 0 && active_from_vectors.features.length > 0) {
        temp_gcp_status = true;
        document.getElementById("addPointDiv").className = "addPointHighlighted";
        document.getElementById("GcpButton").disabled = false;
    } else {
        temp_gcp_status = false;
    }
}

function newaddGCPto(feat) {
  if (active_to_vectors.features.length > 1) {
    var to_destroy = new Array();
    for (var a=0; a< active_to_vectors.features.length; a++) {
      if (active_to_vectors.features[a] != feat) {
        to_destroy.push(active_to_vectors.features[a]);
      }
    }
    active_to_vectors.destroyFeatures(to_destroy);
  }
  var lonlat = new OpenLayers.LonLat(feat.geometry.x, feat.geometry.y);
  highlight(to_map.div);

  to_templl = lonlat;
  check_if_gcp_ready();
}

function newaddGCPfrom(feat) {
  if (active_from_vectors.features.length > 1) {
    var to_destroy = new Array();
    for (var a=0; a< active_from_vectors.features.length; a++) {
      if (active_from_vectors.features[a] != feat) {
        to_destroy.push(active_from_vectors.features[a]);
      }
    }
    active_from_vectors.destroyFeatures(to_destroy);
  }
  var lonlat = new OpenLayers.LonLat(feat.geometry.x, feat.geometry.y);
  highlight(from_map.div);

  from_templl = lonlat;
  check_if_gcp_ready();
}

function addLayerToDest(frm){
    num =frm.layer_num.value;
    new_wms_url = empty_wms_url+'/'+num;

    new_warped_layer = new OpenLayers.Layer.WMS.Untiled("warped map "+num, new_wms_url, 
        {   format: 'image/png', status: 'warped' },
        {   TRANSPARENT: 'true', reproject: 'true' },
        {   gutter: 15, buffer: 0},
        {   projection: "epsg:4326", units: "m"}
    );
    new_warped_layer.setOpacity(.6);
    new_warped_layer.setVisibility(true);
    new_warped_layer.setIsBaseLayer(false);
    to_map.addLayer(new_warped_layer);

    to_layer_switcher.maximizeControl();

    Element.hide('add_layer');

}

function resetHighlighting(){
  to_map.div.className = "map-off";
  from_map.div.className = "map-off";
  document.getElementById("addPointDiv").className = "addPoint";
  document.getElementById("GcpButton").disabled = true;
}

function highlight(thingToHighlight){
  thingToHighlight.className = "highlighted";
}


//TODO deprecate these transform methods to use OL's transform command
function mercatorToLonLat(merc) {
    var lon = (merc.lon / 20037508.34) * 180;
    var lat = (merc.lat / 20037508.34) * 180;

    lat = 180 / Math.PI * (2 * Math.atan(Math.exp(lat * Math.PI / 180)) - Math.PI / 2);

    return new OpenLayers.LonLat(lon, lat);
}

function lonLatToMercator(ll) {
    var lon = ll.lon * 20037508.34 / 180;
    var lat = Math.log(Math.tan((90 + ll.lat) * Math.PI / 360)) / (Math.PI / 180);

    lat = lat * 20037508.34 / 180;

    return new OpenLayers.LonLat(lon, lat);
}


function lonLatToMercatorBounds(llbounds){
  var proj = new OpenLayers.Projection("EPSG:4326");
  var newbounds = llbounds.transform(proj, to_map.getProjectionObject());

  return newbounds;

}

//this function is called is a map has no gcps, and fuzzy best guess
//locations are found. This uses Yahoo's Placemaker service.
function bestGuess(guessObj){
  jQuery("#to_map_notification").hide();
  if (guessObj["status"] == "ok" && guessObj["count"] > 0){
    var siblingExtent = guessObj["sibling_extent"];
    zoom = 10;
    if (siblingExtent){
      sibBounds = new OpenLayers.Bounds.fromString(siblingExtent);
      zoom = to_map.getZoomForExtent(sibBounds.transform(to_map.displayProjection, to_map.projection));
    }
    var places = guessObj["places"];
    var message = "Map zoomed to best guess: "+
      "<a href='#' onclick='centerToMap("+places[0].lon+","+places[0].lat+","+zoom+");return false;'>"+places[0].name + "</a><br />";
    centerToMap(places[0].lon, places[0].lat, zoom);

    if (places.length > 1) {
     message = message + "Other places:<br />";
      for (var i = 1; i< places.length; i++){
        var place = places[i];
        message = message + "<a href='#' onclick='centerToMap("+place.lon+","+place.lat+","+zoom+");return false;'>"+place.name + "</a><br />"
      }
    }
    jQuery("#to_map_notification_inner").html(message);
    jQuery("#to_map_notification").show('slow');
  }

}
function centerToMap(lon, lat, zoom){
  var newCenter = new OpenLayers.LonLat(lon, lat).transform(to_map.displayProjection, to_map.projection);
  to_map.setCenter(newCenter, zoom);
}
