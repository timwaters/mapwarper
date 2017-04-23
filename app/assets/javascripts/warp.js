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
var transformation = new ol.transform.Helmert();
var dialogOpen = false;

///////////////////////////////////////////////////////////////////////////////////////////
//
// INIT
//
///////////////////////////////////////////////////////////////////////////////////////////
function init() {

  from_map = new OpenLayers.Map('from_map', {
    controls: [new OpenLayers.Control.PanZoomBar()],
    maxExtent: new OpenLayers.Bounds(0, 0, image_width, image_height),
    maxResolution: 'auto',
    numZoomLevels: 20
  });
  //  from_map.addControl(new OpenLayers.Control.MousePosition());

  var image = new OpenLayers.Layer.WMS(title,
          wms_url, {
            format: 'image/png',
            status: 'unwarped'},
  {
    transitionEffect: 'resize'
  });

  from_map.addLayer(image);

  if (!from_map.getCenter()) {
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
    maxExtent: new OpenLayers.Bounds(-20037508, -20037508, 20037508, 20037508.34),
    controls: [new OpenLayers.Control.Attribution(), to_layer_switcher, new OpenLayers.Control.PanZoomBar()]
  };

  to_map = new OpenLayers.Map('to_map', options);

  warped_layer = new OpenLayers.Layer.WMS.Untiled("warped map", wms_url, {
    format: 'image/png',
    status: 'warped'},
  {TRANSPARENT: 'true', reproject: 'true'},
  {gutter: 15, buffer: 0},
  {projection: "epsg:4326", units: "m"}
  );


  var warpedOpacity = 0.6;
  warped_layer.setOpacity(warpedOpacity);
  warped_layer.setVisibility(false);
  warped_layer.setIsBaseLayer(false);
  to_map.addLayer(warped_layer);

  to_map.addLayer(mapnik);


  for (var i = 0; i < layers_array.length; i++) {
    to_map.addLayer(get_map_layer(layers_array[i]));
  }


  satellite.setVisibility(false);
  to_map.addLayer(satellite);

  if (map_has_bounds) {
    map_bounds_merc = new OpenLayers.Bounds();
    map_bounds_merc = lonLatToMercatorBounds(map_bounds);

    to_map.zoomToExtent(map_bounds_merc);

  } else {
    //set to the world
    to_map.setCenter(lonLatToMercator(new OpenLayers.LonLat(0.0, 0.0)), 3);
  }

  //style for the active, temporary vector marker, the one the user actually adds themselves,
  var active_style = OpenLayers.Util.extend({},
          OpenLayers.Feature.Vector.style['default']);
  active_style.graphicOpacity = 1;
  active_style.graphicWidth = 14;
  active_style.graphicHeight = 22;
  active_style.graphicXOffset = -(active_style.graphicWidth / 2) - 2;
  active_style.graphicYOffset = -active_style.graphicHeight - 2;
  active_style.externalGraphic = icon_imgPath + "AQUA.png";

  to_vectors = new OpenLayers.Layer.Vector("To vector markers");
  to_vectors.displayInLayerSwitcher = false;

  from_vectors = new OpenLayers.Layer.Vector("From vector markers");
  from_vectors.displayInLayerSwitcher = false;

  active_to_vectors = new OpenLayers.Layer.Vector("active To vector markers", {style: active_style});
  active_to_vectors.displayInLayerSwitcher = false;

  active_from_vectors = new OpenLayers.Layer.Vector("active from vector markers", {style: active_style});
  active_from_vectors.displayInLayerSwitcher = false;

  to_map.addLayers([to_vectors, active_to_vectors]);
  from_map.addLayers([from_vectors, active_from_vectors]);

  var to_panel = new OpenLayers.Control.Panel(
          {displayClass: 'toPanel olControlEditingToolbar'}
  );
  var dragMarker = new OpenLayers.Control.DragFeature(to_vectors,
          {displayClass: 'olControlDragFeature', title: I18n["warp"]["move_gcp"]});
  dragMarker.onComplete = function(feature) {
    saveDraggedMarker(feature);
  };

  var drawFeatureTo = new OpenLayers.Control.DrawFeature(active_to_vectors, OpenLayers.Handler.Point,
          {displayClass: 'olControlDrawFeaturePoint', title: I18n["warp"]["add_gcp"], handlerOptions: {style: active_style}});
  drawFeatureTo.featureAdded = function(feature) {
    newaddGCPto(feature);
  };
  
  var drawFeatureFrom = new OpenLayers.Control.DrawFeature(active_from_vectors, OpenLayers.Handler.Point,
          {displayClass: 'olControlDrawFeaturePoint', title: I18n["warp"]["add_gcp"], handlerOptions: {style: active_style}});
  drawFeatureFrom.featureAdded = function(feature) {
    newaddGCPfrom(feature);
  };

  var from_panel = new OpenLayers.Control.Panel(
          {displayClass: 'olControlEditingToolbar'}
  );
  var dragMarkerFrom = new OpenLayers.Control.DragFeature(from_vectors,
          {displayClass: 'olControlDragFeature', title: I18n["warp"]["move_gcp"]});
  dragMarkerFrom.onComplete = function(feature) {
    saveDraggedMarker(feature);
  };
  
 
  function addCustomLayerAction() {

    var dialog = jQuery("#add_custom_layer").dialog({
      bgiframe: true,
      height: 350,
      width: 500,
      resizable: false,
      draggable: false,
      modal: true,
      hide: 'slow',
      title: I18n["warp"]["custom_layer_title"],
      buttons: [{
          text: I18n["warp"]["custom_layer_add_layer_button"],
          click: function () {
            var selected = jQuery('.layer-select').select2("data")[0];
            if (selected.tiles) {
              var layer = {"title": selected.title, "type": selected.type, "template": selected.tiles};
              addCustomLayer(layer);
            }
            dialog.dialog("close");
            form[ 0 ].reset();
          }
        },
        {
          text: I18n["warp"]["custom_layer_cancel_button"],
          click: function () {
            form[ 0 ].reset();
            dialog.dialog("close");
          }
        }],
      open: function(){
        dialogOpen = true;
      },
      close: function () {
        dialogOpen = false;
        form[ 0 ].reset();
      }
    });
    
  var form = dialog.find( "form" ).on( "submit", function( event ) {
      var template = jQuery("#template").val();
      event.preventDefault();
      addCustomLayer(template);
      dialog.dialog("close"); 
    });
   
 }
  function addCustomLayer(layer) {
    var template = layer.template;
    var title = "";
    var type = layer.type;
    var attribution = "";
    var tokens = template.split("/")
    var basetokens = tokens.slice(0, tokens.length - 3)
    var baseurl = basetokens.join("/") + "/";
    var img_type = template.split(".").pop()
    if (basetokens.length <= 0){
      return false;
    } 
  
    if (type == "Custom") {
      title = I18n["warp"]["custom_layer"];
      attribution = I18n["warp"]["custom_layer"] + " " + baseurl
    } else {
      title = type + ": " + layer.title.substring(0,20);
      attribution = title + " " + baseurl
    }
    
  
    var temp_layer = new OpenLayers.Layer.TMS(title, baseurl,
            {type: img_type,
              getURL: osm_getTileURL,
              displayOutsideMaxExtent: true,
              transitionEffect: 'resize',
              attribution: attribution
            }
    );

    temp_layer.setVisibility(true);
    temp_layer.setIsBaseLayer(true);
    to_map.addLayer(temp_layer);
    to_map.setBaseLayer(temp_layer)
    to_layer_switcher.maximizeControl();
    jQuery('#add_layer').hide();
  }
  
  var layerButton = new OpenLayers.Control.Button({
    displayClass: 'layerButton', title: I18n["warp"]["custom_layer_title"], trigger: addCustomLayerAction 
 });


  navig = new OpenLayers.Control.Navigation({title: I18n["warp"]["move_map"]});
  navigFrom = new OpenLayers.Control.Navigation({title: I18n["warp"]["move_map"]});

  to_panel.addControls([layerButton, navig, dragMarker, drawFeatureTo]);
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
  warped_layer.events.register('visibilitychanged', this, function(layer) {
    if (layer.object.getVisibility() === true) {
      jQuery("#warped-slider").show();
    } else {
      jQuery("#warped-slider").hide();
    }
  });
  
  setupLayerSelect();
 
  var toPosition;
  var fromPosition;
  var mapUnderMouse = "";
  to_map.events.register("mousemove", to_map, function (e) {
    toPosition = this.events.getMousePosition(e);
    mapUnderMouse = "to_map";
  })
  from_map.events.register("mousemove", from_map, function (e) {
    fromPosition = this.events.getMousePosition(e);
    mapUnderMouse = "from_map";
  })

  //control for keyboard shortcuts for map control    
  var barControl = new OpenLayers.Control();
  var barCallbacks = {
    keydown: function (evt) {
      if (dialogOpen === true) return true;
      var key = evt.keyCode;
      if (key == 81 || key == 65) {
        // q key - quick add point - any mode control
        // a key - quick point but with auto placement
        if (mapUnderMouse == "to_map") {
          var point = to_map.getLonLatFromPixel(toPosition);
          var thisVector = new OpenLayers.Geometry.Point(point.lon, point.lat);
          var pointFeature = new OpenLayers.Feature.Vector(thisVector, null, null);
          active_to_vectors.addFeatures([pointFeature]);
          newaddGCPto(pointFeature);
          if (key == 65) addAutoFromPoint(pointFeature);
        } else if (mapUnderMouse == "from_map") {
          var point = from_map.getLonLatFromPixel(fromPosition);
          var thisVector = new OpenLayers.Geometry.Point(point.lon, point.lat);
          var pointFeature = new OpenLayers.Feature.Vector(thisVector, null, null);
          active_from_vectors.addFeatures([pointFeature]);
          newaddGCPfrom(pointFeature);
          if (key == 65) addAutoToPoint(pointFeature);
        }

      } else if (key == 80 || key == 49) {
        // 1, p = (place point)
        navig.deactivate();
        dragMarker.deactivate();
        drawFeatureFrom.activate();
      } else if (key == 68 || key == 50) {
        // 2, d (drag point)
        navig.deactivate();
        dragMarker.activate()
        drawFeatureTo.deactivate();
      } else if (key == 77 || key == 51) {
        //3, m (move point)
        drawFeatureFrom.deactivate();
        dragMarker.deactivate();
        navig.activate();
      }
    }
  };
  var barHandler = new OpenLayers.Handler.Keyboard(barControl, barCallbacks, {});
  barHandler.activate();

  //control for saving a new gcp by pressing 'ENTER' or 'e' keys
  var saveControl = new OpenLayers.Control();
  var saveCallbacks = {
    keydown: function (evt) {
      if (dialogOpen === true) return true;
      if (evt.keyCode == 13 || evt.keyCode == 69) {
        check_if_gcp_ready();
        if (temp_gcp_status) {
          set_gcp();
        }
      }
    }
  };
  var saveHandler = new OpenLayers.Handler.Keyboard(saveControl, saveCallbacks, {});
  saveHandler.activate();


}



//set points for transformation
function setTransformPoints() {
  xy = [];
  XY = [];
  for (var i = 0; i < from_vectors.features.length; i++) {
    xy.push([from_vectors.features[i].geometry.x, from_vectors.features[i].geometry.y]);
    XY.push([to_vectors.features[i].geometry.x, to_vectors.features[i].geometry.y]);
  }
  transformation.setControlPoints(xy, XY);
}

function transform(xy) {
  var pt = transformation.transform(xy);
  return pt;
}
function reverseTransform(xy) {
  var pt = transformation.revers(xy);
  return pt;
}

function addAutoFromPoint(feature) {
  setTransformPoints();
  var from_auto_pt = transformation.revers([feature.geometry.x, feature.geometry.y]);
  var thisVector = new OpenLayers.Geometry.Point(from_auto_pt[0], from_auto_pt[1]);
  var pointFeature = new OpenLayers.Feature.Vector(thisVector, null, null);
 // if (active_from_vectors.features.length === 0) {
    active_from_vectors.addFeatures([pointFeature]);
    newaddGCPfrom(pointFeature);
    var center = new OpenLayers.LonLat(thisVector.x,thisVector.y);
    from_map.setCenter(center);
  //}
}

function addAutoToPoint(feature) {
  setTransformPoints();
  var to_auto_pt = transformation.transform([feature.geometry.x, feature.geometry.y]);
  var thisVector = new OpenLayers.Geometry.Point(to_auto_pt[0], to_auto_pt[1]);
  var pointFeature = new OpenLayers.Feature.Vector(thisVector, null, null);
 // if (active_to_vectors.features.length === 0) {
    active_to_vectors.addFeatures([pointFeature]);
    newaddGCPto(pointFeature);
    var center2 = new OpenLayers.LonLat(thisVector.x, thisVector.y);   
    to_map.setCenter(center2);
 // }
}

function joinControls(first, second) {
  first.events.register("activate", first, function() {
    second.activate();
  });
  first.events.register("deactivate", first, function() {
    second.deactivate();
  });
  second.events.register("activate", second, function() {
    first.activate();
  });
  second.events.register("deactivate", second, function() {
    first.deactivate();
  });
}

function get_map_layer(layerid) {
  var newlayer_url = layer_baseurl + "/" + layerid;
  var map_layer = new OpenLayers.Layer.WMS
          ("Mosaic " + layerid,
                  newlayer_url,
                  {format: 'image/png'},
          {TRANSPARENT: 'true', reproject: 'true'},
          {gutter: 15, buffer: 0},
          {projection: "epsg:4326", units: "m"}
          );
  map_layer.setIsBaseLayer(false);
  map_layer.visibility = false;

  return map_layer;
}


var moving = false;
var origXYZ = new Object();

function moveStart(mapEvent) {
  var passiveMap;
  var activeMap;
  if (this == 1) {
    activeMap = from_map;
    passiveMap = to_map;
  } else {
    activeMap = to_map;
    passiveMap = from_map;
  }
  var cent = activeMap.getCenter();
  origXYZ.lonlat = cent;
  origXYZ.zoom = activeMap.zoom;
}


function moveEnd(mapEvent) {
  if (moving) {
    return;
  }
  moving = true;
  var passiveMap;
  var activeMap;
  if (this == 1) {
    activeMap = from_map;
    passiveMap = to_map;
  } else {
    activeMap = to_map;
    passiveMap = from_map;
  }
  var newZoom = passiveMap.zoom;
  if (origXYZ.zoom != activeMap.zoom) {
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
function toggleJoinLinks() {
  //TODO change the icon
  if (mapLinked === true) {
    mapLinked = false;
    document.getElementById('link-map-button').className = 'link-map-button-off';
  } else {
    mapLinked = true;
    document.getElementById('link-map-button').className = 'link-map-button-on';
  }
  if (mapLinked === true) {
    from_map.events.register("moveend", 1, moveEnd);
    to_map.events.register("moveend", 0, moveEnd);
    from_map.events.register("movestart", 1, moveStart);
    to_map.events.register("movestart", 0, moveStart);
  } else {
    from_map.events.unregister("moveend", 1, moveEnd);
    to_map.events.unregister("moveend", 0, moveEnd);
    from_map.events.unregister("movestart", 1, moveStart);
    to_map.events.unregister("movestart", 0, moveStart);
  }
}

function gcp_notice(text) {
  //jquery effect
  jqHighlight('rectifyNotice');
  notice = document.getElementById('gcp_notice');
  notice.innerHTML = text;
}

function update_gcp_field(gcp_id, elem) {
  var id = gcp_id;
  var value = elem.value;
  var attrib = elem.id.substring(0, (elem.id.length - (id + "").length));
  var url = gcp_update_field_url + "/" + id;

  jQuery('#spinner').show();
  gcp_notice(I18n["warp"]["gcp_updating"]);

  var request = jQuery.ajax({
    type: "PUT",
    url: url,
    data: {authenticity_token: encodeURIComponent(window._token), attribute: attrib, value: value}}
  ).success(function() {
    gcp_notice(I18n["warp"]["gcp_updated"]);
    move_map_markers(gcp_id, elem);
  }).done(function() {
    jQuery('#spinner').hide();
  }).fail(function() {
    gcp_notice(I18n["warp"]["gcp_failed"]);
    elem.value = value;
  });
}

function update_gcp(gcp_id, listele) {
  var id = gcp_id;
  var url = gcp_update_url + "/" + id;

  for (i = 0; i < listele.childNodes.length; i++) {
    listtd = listele.childNodes[i]; //td
    for (e = 0; e < listtd.childNodes.length; e++) {

      listItem = listtd.childNodes[e];//input
      if (listItem.id == "x" + gcp_id) {
        x = listItem.value;
      }
      if (listItem.id == "y" + gcp_id) {
        y = listItem.value;
      }
      if (listItem.id == "lon" + gcp_id) {
        lon = listItem.value;
      }
      if (listItem.id == "lat" + gcp_id) {
        lat = listItem.value;
      }

    }
  }
  gcp_notice(I18n["warp"]["gcp_updating"]);
  jQuery('#spinner').show();
  
  var request = jQuery.ajax({
    type: "PUT",
    url: url,
    data: {authenticity_token: encodeURIComponent(window._token), x: x, y: y, lon: lon, lat: lat}}
  ).success(function() {
    gcp_notice(I18n["warp"]["gcp_updated"]);
  }).done(function() {
    jQuery('#spinner').hide();
  }).fail(function() {
    gcp_notice(I18n["warp"]["gcp_failed"]);
    elem.value = value;
  });

}

function move_map_markers(gcp_id, elem) {
  var avalue = elem.value;
  var attrib = elem.id;
  trele = elem.parentNode.parentNode; //input>td>tr
  //get the other siblings next door to this one.
  for (i = 0; i < trele.childNodes.length; i++) {
    trchild = trele.childNodes[i]; //tds
    for (e = 0; e < trchild.childNodes.length; e++) {

      inp = trchild.childNodes[e]; //inputs
      if (inp.id == 'x' + gcp_id) {
        x = inp.value;
      }
      if (inp.id == 'y' + gcp_id) {
        y = image_height - inp.value;
      }
      if (inp.id == 'lon' + gcp_id) {
        tlon = inp.value;
      }
      if (inp.id == 'lat' + gcp_id) {
        tlat = inp.value;
      }
    }
  }

  if (attrib == 'x' + gcp_id || attrib == 'y' + gcp_id) {
    var frommark;
    for (var a = 0; a < from_vectors.features.length; a++) {
      if (from_vectors.features[a].gcp_id == gcp_id) {
        frommark = from_vectors.features[a];
      }//if
    } //for
    if (attrib == 'x' + gcp_id) {
      x = avalue;
    }
    if (attrib == 'y' + gcp_id) {
      y = image_height - avalue;
    }
    //frommark.geometry.move(new OpenLayers.LonLat(x, y));
    frommark.geometry.x = x;
    frommark.geometry.y = y;
    frommark.geometry.clearBounds();
    frommark.layer.drawFeature(frommark);
  }

  else if (attrib == 'lon' + gcp_id || attrib == 'lat' + gcp_id) {
    var tomark;
    for (var b = 0; b < to_vectors.features.length; b++) {
      if (to_vectors.features[b].gcp_id == gcp_id) {
        tomark = to_vectors.features[b];
      } //if
    }//for
    if (attrib == 'lon' + gcp_id) {
      tlon = avalue;
    }
    if (attrib == 'lat' + gcp_id) {
      tlat = avalue;
    }

    hacklonlat = lonLatToMercator(new OpenLayers.LonLat(tlon, tlat));
    tomark.geometry.x = hacklonlat.lon;
    tomark.geometry.y = hacklonlat.lat;
    tomark.geometry.clearBounds();
    tomark.layer.drawFeature(tomark);
  }
}

//when a vector marker is dragged, update values on form and save
function saveDraggedMarker(feature) {

  var listele = document.getElementById("gcp" + feature.gcp_id); //listele is a tr
  for (i = 0; i < listele.childNodes.length; i++) {
    listtd = listele.childNodes[i];//listtd is a td

    for (e = 0; e < listtd.childNodes.length; e++) {
      listItem = listtd.childNodes[e]; //listitem is the input field

      if (feature.layer == from_vectors) {
        if (listItem.id == "x" + feature.gcp_id) {
          listItem.value = feature.geometry.x;
        }
        if (listItem.id == "y" + feature.gcp_id) {
          listItem.value = image_height - feature.geometry.y;
        }
      }
      if (feature.layer == to_vectors) {
        var merc = new OpenLayers.LonLat(feature.geometry.x, feature.geometry.y);
        var vll = mercatorToLonLat(merc);
        if (listItem.id == "lon" + feature.gcp_id) {
          listItem.value = vll.lon;
        }
        if (listItem.id == "lat" + feature.gcp_id) {
          listItem.value = vll.lat;
        }
      }
    }//for
  }//for
  update_gcp(feature.gcp_id, listele);
}

function save_new_gcp(x, y, lon, lat) {

  url = gcp_add_url;
  gcp_notice(I18n["warp"]["gcp_adding"]);
  jQuery('#spinner').show();
  
  var request = jQuery.ajax({
    type: "POST",
    url: url,
    data: {authenticity_token: encodeURIComponent(window._token), x: x, y: y, lat: lat, lon: lon}}
  ).done(function() {
    update_row_numbers();
    jQuery('#spinner').hide();
  }).fail(function() {
    gcp_notice(I18n["warp"]["gcp_failed"]);
  });
  
}


function update_rms(new_rms) {
  fi = document.getElementById('errortitle');
  fi.innerHTML=  I18n["warp"]["rms_error_prefix"]+"(" + new_rms + ")";
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
function update_row_numbers() {
  for (var a = 0; a < from_vectors.features.length; a++) {
    temp_marker = from_vectors.features[a];
    li_ele = document.getElementById("gcp" + temp_marker.gcp_id);

    ////////////////
    inputs = li_ele.getElementsByTagName("input");
    for (var b = 0; b < inputs.length; b++) {
      if (inputs[b].name == "error" + temp_marker.gcp_id) {
        error = inputs[b].value;
      }
    }
    var color = getColorString(error);
    updateGcpColor(from_vectors.features[a], color);
    updateGcpColor(to_vectors.features[a], color);
    ////////////

    span_ele = li_ele.getElementsByTagName("span");
    if (span_ele[0].className == "marker_number") {
      var thishtml = "<img src='" + icon_imgPath + (temp_marker.id_index + 1) + color + ".png' />";
      //var thishtml = "<img src='../../images/icons/"+(temp_marker.id_index + 1) + ".png' />";
      span_ele[0].innerHTML = thishtml;
    }
  }
  redrawGcpLayers();
}



function redrawGcpLayers() {
  from_vectors.redraw();
  to_vectors.redraw();
}


function updateGcpColor(marker, color) {
  marker.style.externalGraphic = icon_imgPath + (marker.id_index + 1) + color + '.png';
}



//blue, green, orange, red
function getColorString(error) {
  var colorString = "";
  if (error < 5) {
    colorString = "";
  } else if (error >= 5 && error < 10) {
    colorString = "_green";
  } else if (error >= 10 && error < 50) {
    colorString = "_orange";
  } else if (error >= 50) {
    colorString = "_red";
  }
  //TODO
  return colorString;
  //return "";
}


function populate_gcps(gcp_id, img_lon, img_lat, dest_lon, dest_lat, error) {
  error = typeof (error) != "undefined" ? error : 0;
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
  if (!temp_gcp_status) {
    alert(I18n["warp"]["gcp_premature_alert"]);
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
  color = typeof (color) != "undefined" ? color : "";
  id_index = typeof (id_index) != 'undefined' ? id_index : -2;
  var style_mark = OpenLayers.Util.extend({},
          OpenLayers.Feature.Vector.style['default']);
  style_mark.graphicOpacity = 1;
  style_mark.graphicWidth = 14;
  style_mark.graphicHeight = 22;
  style_mark.graphicXOffset = -(style_mark.graphicWidth / 2);
  style_mark.graphicYOffset = -style_mark.graphicHeight;
  if (is_active_marker === true) {
    active_style.externalGraphic = icon_imgPath + "AQUA.png";
  } else {
    style_mark.externalGraphic = icon_imgPath + (id_index + 1) + color + '.png';
  }
  var thisVector = new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat);
  var pointFeature = new OpenLayers.Feature.Vector(thisVector, null, style_mark);
  pointFeature.id_index = id_index;
  pointFeature.gcp_id = gcp_id;

  markers_layer.addFeatures([pointFeature]);

  resetHighlighting();
}


function show_warped_map() {
  warped_layer.setVisibility(true);
  warped_layer.mergeNewParams({'random': Math.random()});
  warped_layer.redraw(true);
  to_layer_switcher.maximizeControl();

  //cross tab issue - reloads the rectified map in the preview tab if its there
  if (typeof warpedmap != 'undefined' && typeof warped_wmslayer != 'undefined') {
    warped_wmslayer.mergeNewParams({'random': Math.random()});
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
    for (var a = 0; a < active_to_vectors.features.length; a++) {
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
    for (var a = 0; a < active_from_vectors.features.length; a++) {
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



function resetHighlighting() {
  to_map.div.className = "map-off";
  from_map.div.className = "map-off";
  document.getElementById("addPointDiv").className = "addPoint";
  document.getElementById("GcpButton").disabled = true;
}

function highlight(thingToHighlight) {
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


function lonLatToMercatorBounds(llbounds) {
  var proj = new OpenLayers.Projection("EPSG:4326");
  var newbounds = llbounds.transform(proj, to_map.getProjectionObject());

  return newbounds;

}

//this function is called is a map has no gcps, and fuzzy best guess
//locations are found. This uses Yahoo's Placemaker service.
function bestGuess(guessObj) {
  jQuery("#to_map_notification").hide();
  if (guessObj["status"] == "ok" && guessObj["count"] > 0) {
    var siblingExtent = guessObj["sibling_extent"];
    zoom = 10;
    if (siblingExtent) {
      sibBounds = new OpenLayers.Bounds.fromString(siblingExtent);
      zoom = to_map.getZoomForExtent(sibBounds.transform(to_map.displayProjection, to_map.projection));
    }
    var places = guessObj["places"];
    var message = I18n["warp"]["best_guess_message"]+ " " +
            "<a href='#' onclick='centerToMap(" + places[0].lon + "," + places[0].lat + "," + zoom + ");return false;'>" + places[0].name + "</a><br />";
    centerToMap(places[0].lon, places[0].lat, zoom);

    if (places.length > 1) {
      message = message + I18n["warp"]["other_places"]+":<br />";
      for (var i = 1; i < places.length; i++) {
        var place = places[i];
        message = message + "<a href='#' onclick='centerToMap(" + place.lon + "," + place.lat + "," + zoom + ");return false;'>" + place.name + "</a><br />"
      }
    }
    jQuery("#to_map_notification_inner").html(message);
    jQuery("#to_map_notification").show('slow');
  }

}
function centerToMap(lon, lat, zoom) {
  var newCenter = new OpenLayers.LonLat(lon, lat).transform(to_map.displayProjection, to_map.projection);
  to_map.setCenter(newCenter, zoom);
}

var customId = 10000;
function setupLayerSelect() {
  jQuery('.layer-select').select2({
    ajax: {
      url: "/search.json",
      dataType: 'json',
      delay: 250,
      transport: function (params, success, failure) {
        if (params.data && params.data.query.indexOf("http") === 0) {
          var title = params.data.query;
          customId = customId + 1
          var id = customId;
          jQuery('.layer-select').data('select2').dataAdapter.select({"id": id, "type": "Custom", "title": title, "description": "", "href": params.data.query, "thumb": "/uploads/6/thumb/NYC1776-mod.png", "tiles": params.data.query, "year": null})
          return null;
        } else {
          $request = jQuery.ajax(params);
          $request.then(success);
          $request.fail(failure);

          return $request;
        }
      },
      data: function (params) {
        return {
          query: params.term
        };

      },
      processResults: function (data, params) {
        params.page = params.page || 1;

        return {
          results: data.data,
          pagination: {
            more: (params.page * 50) < data.total_count
          }
        };

      },
      cache: true
    },
    escapeMarkup: function (markup) {
      return markup;
    },
    allowClear: true,
    minimumInputLength: 3,
    templateResult: formatItems,
    templateSelection: formatItemSelection
  });

  function formatItems(item) {
    if (item.loading)
      return item.title;
    
    var itemType = getItemType(item);
    var markup = "<div class='select2-result-item clearfix'>" +
            "<div class='select2-result-item__thumb'><img src='" + item.thumb + "' /></div>" +
            "<div class='select2-result-item__meta'>" +
            "<div class='select2-result-item__title'><span class='select2-result-item__type'>" + itemType + ":</span> " + item.title + "</div>";

    if (item.year) {
      markup += "<div class='select2-result-item__year'>"+ I18n['warp']['custom_layer_year'] +": " + item.year + "</div>";
    }

    markup += "</div></div>";

    return markup;
  }

  function formatItemSelection(item) {
    var itemType = getItemType(item); 
    if (item.id === "") {
      return item.text; //placeholder text
    } else {
      return itemType + ": " + item.title;
    }
  }
  
  function getItemType(item){
    var itemType = "";
    if (item.type === "Map"){
      itemType = I18n['warp']['custom_map_type'];
    } else if (item.type === "Layer") {
      itemType = I18n['warp']['custom_layer_type'];
    } else {
      itemType = I18n['warp']['custom_custom_type']
    }
    
    return itemType;
  }



}
