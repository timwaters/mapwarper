var temp_gcp_status = false;
var from_templl;
var to_templl;
var warped_layer; //the warped wms layer
var to_layer_switcher; 

var to_vectors;
var from_vectors;
var active_to_vectors;
var active_from_vectors;


/////////////////////////////////////
///INIT
////////////////////////////////////
function init() {
//    mds = new OpenLayers.Control.MouseDefaults();
//OpenLayers.ImgPath = "../../javascripts/openlayers/img/"
    from_map = new OpenLayers.Map('from_map', {
        theme: null,
        controls: [ new OpenLayers.Control.PanZoomBar()],
        maxExtent: new OpenLayers.Bounds(0, 0, image_width, image_height),
        maxResolution: 'auto',
        numZoomLevels: 8
    });
    from_map.addControl(new OpenLayers.Control.MousePosition());

    var image = new OpenLayers.Layer.WMS( title,
        wms_url, {
        format: 'image/png',
        status: 'unwarped'},
    { gutter: 15, buffer:0},
        {
        transitionEffect: 'resize'
        } );

    from_map.addLayer(image);

    if (!from_map.getCenter()) {
        from_map.zoomToMaxExtent();
    }

    OpenLayers.IMAGE_RELOAD_ATTEMPTS = 3;
    OpenLayers.Util.onImageLoadErrorColor = "transparent";

    to_layer_switcher = new OpenLayers.Control.LayerSwitcher();
    var options = {
        theme: null,
        projection: new OpenLayers.Projection("EPSG:900913"),
        displayProjection: new OpenLayers.Projection("EPSG:4326"),
        units: "m",
        numZoomLevels: 19,
        maxResolution: 156543.0339,
        maxExtent: new OpenLayers.Bounds( - 20037508, -20037508, 20037508, 20037508.34),
        controls: [ new OpenLayers.Control.Attribution(), to_layer_switcher, new OpenLayers.Control.PanZoomBar(), new OpenLayers.Control.MousePosition()]
    };

    to_map = new OpenLayers.Map('to_map', options);

     warped_layer = new OpenLayers.Layer.WMS.Untiled("warped map", wms_url, {
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
    warped_layer.setOpacity(.6);
    warped_layer.setVisibility(false);
    warped_layer.setIsBaseLayer(false);
    to_map.addLayer(warped_layer);

    to_map.addLayer(mapnik);
    to_map.addLayer(osma);
    to_map.addLayer(oamlayer);
    jpl_wms.setVisibility(false);
    to_map.addLayer(jpl_wms);

    //to_map.addLayer(googleSat);

    if (map_has_bounds) {

        map_bounds_merc = new OpenLayers.Bounds();
        map_bounds_merc  = lonLatToMercatorBounds(map_bounds);

        to_map.zoomToExtent(map_bounds_merc);

    } else {
        to_map.setCenter(lonLatToMercator(new OpenLayers.LonLat(-31.68, 32.57)), 2);

    }

    //style for the active, temporary vector marker, the one the user actually adds themselves,
    var active_style = OpenLayers.Util.extend({},
        OpenLayers.Feature.Vector.style['default']);
    active_style.graphicOpacity = 1;
    active_style.graphicWidth = 14;
    active_style.graphicHeight = 22;
    active_style.graphicXOffset = -(active_style.graphicWidth/2);
    active_style.graphicYOffset = -active_style.graphicHeight;
    active_style.externalGraphic = "../../images/AQUA.png";

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
    OpenLayers.Control.DragFeature.prototype.upFeature = function() {};
    //fix
    var to_panel = new OpenLayers.Control.Panel (
        {displayClass: 'olControlEditingToolbar'}
        );
    var dragMarker = new OpenLayers.Control.DragFeature(to_vectors,
        {displayClass: 'olControlDragFeature', title:'Move Control Point'});
    dragMarker.onComplete = function(feature) {
      saveDraggedMarker(feature);
      dragMarker.deactivate();
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
    var dragMarkerTo = new OpenLayers.Control.DragFeature(from_vectors,
        {displayClass: 'olControlDragFeature', title:'Move Control Point'});
    dragMarkerTo.onComplete = function(feature) {
      saveDraggedMarker(feature);
      dragMarkerTo.deactivate();
    };

    navig = new OpenLayers.Control.Navigation({title: "Move Around Map"});
    navigTo = new OpenLayers.Control.Navigation({title: "Move Around Map"});

    to_panel.addControls([navig, dragMarker, drawFeatureTo]);
    to_map.addControl(to_panel);

    from_panel.addControls([navigTo, dragMarkerTo, drawFeatureFrom]);
    from_map.addControl(from_panel);

    navig.activate();
    navigTo.activate();


} //init

function gcp_notice(text){
notice = document.getElementById('gcp_notice');
notice.innerHTML = text;
}

//updates one field of a gcp, called when user manually edits a gcp
function update_gcp_field(gcp_id, elem) {
    //1. send to server
    var id = gcp_id;
    var value = elem.value;
    var attrib = elem.id;
    var url = gcp_update_field_url + "/" + id;
    
    //console.log(gcp_update_url);
    //onsuccess, or onfailure messages? - rails handles
    Element.show('spinner');

    var options = {
        method: "put",
        parameters: 'authenticity_token=' + encodeURIComponent(window._token) + "&attribute=" + attrib + "&value=" + value,
        asynchronous: true,
        onSuccess: function(transport) {
          gcp_notice("GCP updated");
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
      if (listItem.id == "x") {
          x = listItem.value;
      }
      if (listItem.id == "y") {
          y = listItem.value;
      }
      if (listItem.id == "lon") {
          lon = listItem.value;
      }
      if (listItem.id == "lat") {
          lat = listItem.value;
      }

    }
  }

  Element.show('spinner');
   var options = {
        method: "put",
        parameters: 'authenticity_token=' + encodeURIComponent(window._token) + "&x="+x+"&y="+y+"&lon="+lon+"&lat="+lat,
        asynchronous: true,
        onSuccess: function(transport) {
          gcp_notice("GCP updated");
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
      if (inp.id == 'x') {
          x = inp.value;
      }
      if (inp.id == 'y') {
          y = image_height - inp.value ;
      }
      if (inp.id == 'lon') {
          tlon = inp.value;
      }
      if (inp.id == 'lat') {
          tlat = inp.value;
      }
    }
  }

  if (attrib == 'x' || attrib == 'y') {

    for (var a = 0; a < from_vectors.features.length; a++) {
      if (from_vectors.features[a].gcp_id == gcp_id) {
        var frommark = from_vectors.features[a];
      }//if
    } //for
    if (attrib == 'x') {
        x = avalue;
    }
    if (attrib == 'y') {
        y = image_height - avalue;
    }
    //frommark.geometry.move(new OpenLayers.LonLat(x, y));
    frommark.geometry.x = x;
    frommark.geometry.y = y;
    frommark.geometry.clearBounds();
    frommark.layer.drawFeature(frommark);
  }

  else if (attrib == 'lon' || attrib == 'lat')  {
    for (var b = 0; b < to_vectors.features.length; b++) {
      if (to_vectors.features[b].gcp_id == gcp_id) {
        var  tomark = to_vectors.features[b];
      } //if
    }//for
    if (attrib == 'lon') {
        tlon = avalue;
    }
    if (attrib == 'lat') {
        tlat = avalue;
    }

    hacklonlat = lonLatToMercator(new OpenLayers.LonLat(tlon, tlat));
   //console.log(hacklonlat);
    tomark.geometry.x = hacklonlat.lon;
    tomark.geometry.y = hacklonlat.lat;
    tomark.geometry.clearBounds();
    tomark.layer.drawFeature(tomark);

    //tomark.move(lonLatToMercator(new OpenLayers.LonLat(tlon, tlat))); 
  }
}


//when a vector marker is dragged, update values on form and save
function saveDraggedMarker(feature){
  var listele = document.getElementById(feature.gcp_id); //listele is a tr

  for (i=0;i<listele.childNodes.length; i++){
    listtd = listele.childNodes[i];//listtd is a td

    for (e=0;e<listtd.childNodes.length; e++){
      listItem = listtd.childNodes[e]; //listitem is the input field
     
      if (feature.layer == from_vectors){
        if (listItem.id == "x") {
            listItem.value = feature.geometry.x;
        }
        if (listItem.id == "y") {
            listItem.value = image_height - feature.geometry.y;
        }
      }
      if (feature.layer == to_vectors){
        var merc = new OpenLayers.LonLat(feature.geometry.x,feature.geometry.y);
        var vll = mercatorToLonLat(merc);
        if (listItem.id == "lon") {
            listItem.value = vll.lon;
        }
        if (listItem.id == "lat") {
            listItem.value = vll.lat;
        }
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

          Element.hide('spinner'); },
        onFailure: function(transport) {gcp_notice("Had trouble saving that point to the server. Try again?");
},
        onSuccess: function() {

        }

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
            //from_markers.removeMarker(del_from_mark);
            //del_from_mark.destroy();
            to_vectors.destroyFeatures([del_to_mark]);
           // del_to_mark.destroy();
        }
    }
update_row_numbers();
}
//called after initial populate, each delete, and each add
function update_row_numbers(){
  for (var a = 0; a < from_vectors.features.length; a++) {
    temp_marker = from_vectors.features[a];
    li_ele = document.getElementById(temp_marker.gcp_id);

    span_ele = li_ele.getElementsByTagName("span");
    if (span_ele[0].className == "marker_number"){
      var thishtml = "<img src='../../images/icons/"+(temp_marker.id_index + 1) + ".png' />";
      span_ele[0].innerHTML = thishtml; 
    }
  }
}

function populate_gcps(gcp_id, img_lon, img_lat, dest_lon, dest_lat) {
  //x y lon lat
  // console.log("populate" + gcp_id + " img lon="+img_lon); 
  index = gcp_markers.length;

  gcp_markers.push(index); // 0 to 7 or so
  got_lon = img_lon;
  got_lat = image_height - img_lat;

  add_gcp_marker(from_vectors, new OpenLayers.LonLat(got_lon, got_lat), false, index, gcp_id);

  add_gcp_marker(to_vectors, lonLatToMercator(new OpenLayers.LonLat(dest_lon, dest_lat)), false, index, gcp_id);

}

function set_gcp() {
  check_if_gcp_ready();
    if (!temp_gcp_status ) {
alert("You have to add a new control point on each map before pressing this button :)");
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
return true;
    }

}

function add_gcp_marker(markers_layer, lonlat, is_active_marker, id_index, gcp_id) {
  id_index = typeof(id_index) != 'undefined' ? id_index: -2;
  //console.log("addcgo");
  var style_mark = OpenLayers.Util.extend({},
      OpenLayers.Feature.Vector.style['default']);
  style_mark.graphicOpacity = 1;
  style_mark.graphicWidth = 14;
  style_mark.graphicHeight = 22;
  style_mark.graphicXOffset = -(style_mark.graphicWidth/2);
  style_mark.graphicYOffset = -style_mark.graphicHeight;
  if (is_active_marker == true){
    active_style.externalGraphic = "../../images/AQUA.png"; 
  } else {
    style_mark.externalGraphic = '../../images/icons/'+(id_index + 1) + '.png';
  }
  var thisVector = new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat);
  var pointFeature = new OpenLayers.Feature.Vector(thisVector, null, style_mark);
  pointFeature.id_index = id_index;
  pointFeature.gcp_id = gcp_id;

  markers_layer.addFeatures([pointFeature]);

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
    new_warped_layer.setOpacity(.6);
    new_warped_layer.setVisibility(true);
    new_warped_layer.setIsBaseLayer(false);
    to_map.addLayer(new_warped_layer);

    to_layer_switcher.maximizeControl();

  Element.hide('add_layer');

}

function show_warped_map(){
    //open up layer switcher too?

    warped_layer.setVisibility(true);
    warped_layer.mergeNewParams({
        'random':Math.random()
        });
    warped_layer.redraw(true);
    to_layer_switcher.maximizeControl();

}


function check_if_gcp_ready() {
    if (active_to_vectors.features.length > 0 && active_from_vectors.features.length > 0) {
        temp_gcp_status = true;
    } else {
        temp_gcp_status = false;
    }
    //enable set button
}

function newaddGCPto(feat) {
    if (active_to_vectors.features.length > 1) {
        var to_destroy = new Array();
        for (var a=0; a< active_to_vectors.features.length; a++) {
            if (active_to_vectors.features[a] != feat)  {
                to_destroy.push(active_to_vectors.features[a]);
            }
        }
        active_to_vectors.destroyFeatures(to_destroy);
    }
    var lonlat = new OpenLayers.LonLat(feat.geometry.x, feat.geometry.y);
    // add_gcp_marker(active_to_vectors, lonlat, true);
    to_templl = lonlat;
    check_if_gcp_ready();
}

function newaddGCPfrom(feat) {
    if (active_from_vectors.features.length > 1) {
        var to_destroy = new Array();
        for (var a=0; a< active_from_vectors.features.length; a++) {
            if (active_from_vectors.features[a] != feat)  {
                to_destroy.push(active_from_vectors.features[a]);
            }
        }
        active_from_vectors.destroyFeatures(to_destroy);
    }
    var lonlat = new OpenLayers.LonLat(feat.geometry.x, feat.geometry.y);
    // add_gcp_marker(active_from_vectors, lonlat, true);
    from_templl = lonlat;
  
    check_if_gcp_ready();
}



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
