//OpenLayers.ProxyHost = "/cgi-bin/proxy.cgi?url=";
// reference local blank image
//Ext.BLANK_IMAGE_URL = 'mfbase/ext/resources/images/default/s.gif';
var map;
var activeUser = "demo user";
var digitizerPanel;
var mapPanel;
var digextent;
Ext.onReady(function() {
    Ext.QuickTips.init();
    var store;
    var options, layer;

    // var extent = new OpenLayers.Bounds(-74.163,40.571,-73.7368,40.779);

    //  options = {  maxExtent: new OpenLayers.Bounds(-180, -90, 180, 90)     };
    options = {
      controls: [new OpenLayers.Control.Attribution(),
        new OpenLayers.Control.Navigation(),
        new OpenLayers.Control.PanZoomBar(),
        new OpenLayers.Control.LayerSwitcher()],
      projection: new OpenLayers.Projection("EPSG:900913"),
      displayProjection: new OpenLayers.Projection("EPSG:4326"),
      units: "m",
      numZoomLevels:20,
      maxResolution: 156543.0339,
      maxExtent: new OpenLayers.Bounds(-20037508, -20037508, 20037508, 20037508.34)
    };

    var refLayer = new OpenLayers.Layer.WMS("Layer "+refLayerID,
      refLayerURL,
      { format: 'image/png', layers: 'image' },
      { TRANSPARENT:'true', reproject: 'true'},
      { gutter: 15, buffer:0},
      { projection:"epsg:4326", units: "m" }
    );
    refLayer.transitionEffect = 'resize';
    refLayer.setIsBaseLayer(false);
    refLayer.setOpacity(1);
    refLayer.visibility = true;

    var mapnik_d = mapnik.clone(); 
   
    map = new OpenLayers.Map(options);

    digextent = refLayerBounds.transform(map.displayProjection, map.projection);
    var extent = digextent;

    map.addLayer(mapnik_d);

    map.addLayer(refLayer);

    var setupMap = function(viewport) {
      //called when the viewport / panel is rendered
    };

    //cursorURLStyle = "cursor: url("+cssPath+"cursors/dig-crosshair5.cur), url("+cssPath+"cursors/dig-crosshair5.png) 10 10, default;";
    cursorURLStyle = "cursor: url("+cssPath+"cursors/dig-crosshair5.png) 10 10, url("+cssPath+"cursors/dig-crosshair5.cur),  default;";

     mapPanel = new GeoExt.MapPanel({
        region: 'center',
        map: map,
        id: 'digMapPanel',
        bodyStyle: cursorURLStyle,
        extent: extent
      });
  
 var containingMapPanel = new Ext.Panel({
     items:[mapPanel, {xtype: 'box', el: 'digitizer-slider' }],
     layout:'fit',
     region: 'center'
   });

    function taskZoom(node) {
      var selectedLayer = map.getLayersByName(node.parentMenu.activeLayer)[0];
      var layerExtent = selectedLayer.getDataExtent();
      if (layerExtent){
        map.zoomToExtent(layerExtent);
      }else {
        map.zoomToExtent(initialExtent);
      }
    }


    var buildMaterialsUrl = jsPath + "dig/combo/buildMaterials.json";
    var buildUseTypeUrl = jsPath + "dig/combo/buildUseType2.json";
    var buildUseSubTypeUrl = subtypeURL; //the queryable url that fetches the subtypes ?query=Health 
    var buildLayerProps = [
    // new mapfish.widgets.editing.StringProperty(
    //   {name: 'created_at', showInGrid: false, extFieldCfg: {hidden: true, hideLabel: true}}),
    //new mapfish.widgets.editing.StringProperty(
    //    {name: 'updated_at', showInGrid: false, extFieldCfg: {hidden: true, hideLabel: true}}),
    new mapfish.widgets.editing.StringProperty(
      {name: 'name', label: 'Name', showInGrid: true}),
    new mapfish.widgets.editing.StringProperty(
      {name: 'number', label: 'Number', showInGrid: true}),
    new mapfish.widgets.editing.StringProperty(
      {name: 'street', label: 'Street', showInGrid: true}),
    new mapfish.widgets.editing.ComboStringProperty(
      {name: 'materials', label: 'Materials', url: buildMaterialsUrl, showInGrid: true}),
    new mapfish.widgets.editing.ComboStringProperty(
      {name: 'use_type', label: 'Use Type', url: buildUseTypeUrl, showInGrid: true, linked: 'use-subtype', extFieldCfg: {id:'use-type'}    }),
    new mapfish.widgets.editing.ComboStringProperty(
      {name: 'use_subtype', label: 'Use SubType', url: buildUseSubTypeUrl, showInGrid: true, linkedParent: 'use-type', extFieldCfg:{id:'use-subtype'}}),
    new mapfish.widgets.editing.StringProperty(
      {name: 'comment', label: 'Comment', showInGrid: true}),
    new mapfish.widgets.editing.IntegerProperty(
      {name: 'user_id', showInGrid: false, extFieldCfg: {hidden: true, hideLabel: true}}),
    new mapfish.widgets.editing.IntegerProperty(
      {name: 'layer_id', showInGrid: false, extFieldCfg: {hidden: true, hideLabel: true}}),
    new mapfish.widgets.editing.StringProperty(
      {name: 'layer_year', showInGrid: false, extFieldCfg: {hidden: true, hideLabel: true}})
    ];

    var districtFeatTypeUrl = jsPath +"dig/combo/districtFeatType.json?";
    var districtZoningUrl = jsPath + "dig/combo/districtZoning.json?";
    var districtCountyUrl = jsPath + "dig/combo/districtType.json";
    var districtLayerProps = [
    new mapfish.widgets.editing.StringProperty(
      {name: 'name', label: 'Name', showInGrid: true}),
    new mapfish.widgets.editing.StringProperty(
      {name: 'number', label: 'Number', showInGrid: true}),
    new mapfish.widgets.editing.ComboStringProperty(
      {name: 'feature_type', label: 'Feature Type', url: districtFeatTypeUrl, showInGrid: true}),
    new mapfish.widgets.editing.ComboStringProperty(
      {name: 'zoning', label: 'Zoning', url: districtZoningUrl, showInGrid: true}),
    new mapfish.widgets.editing.ComboStringProperty(
      {name: 'county', label: 'County', url: districtCountyUrl, showInGrid: true}),
    new mapfish.widgets.editing.StringProperty(
      {name: 'block', label: 'Block', showInGrid: true}),
    new mapfish.widgets.editing.StringProperty(
      {name: 'lot', label: 'Lot', showInGrid: true}),
    new mapfish.widgets.editing.StringProperty(
      {name: 'comment', label: 'Comment', showInGrid: true}),
    new mapfish.widgets.editing.IntegerProperty(
      {name: 'user_id', showInGrid: false, extFieldCfg: {hidden: true, hideLabel: true}}),
    new mapfish.widgets.editing.IntegerProperty(
      {name: 'layer_id', showInGrid: false, extFieldCfg: {hidden: true, hideLabel: true}}),
    new mapfish.widgets.editing.StringProperty(
      {name: 'layer_year', showInGrid: false, extFieldCfg: {hidden: true, hideLabel: true}})
    ];

    var poiFeatTypeUrl = jsPath + "dig/combo/poiFeatType.json";
    poiLayerProps = [
    new mapfish.widgets.editing.StringProperty(
      {name: 'name', label: 'Name', showInGrid: true}),
    new mapfish.widgets.editing.ComboStringProperty(
      {name: 'feature_type', label: 'Feature Type', url: poiFeatTypeUrl, showInGrid: true}),
    new mapfish.widgets.editing.StringProperty(
      {name: 'comment', label: 'Comment', showInGrid: true}),
    new mapfish.widgets.editing.IntegerProperty(
      {name: 'user_id', showInGrid: false, extFieldCfg: {hidden: true, hideLabel: true}}),
    new mapfish.widgets.editing.IntegerProperty(
      {name: 'layer_id', showInGrid: false, extFieldCfg: {hidden: true, hideLabel: true}}),
    new mapfish.widgets.editing.StringProperty(
      {name: 'layer_year', showInGrid: false, extFieldCfg: {hidden: true, hideLabel: true}})
    ];

    var transportFeatTypeUrl = jsPath + "dig/combo/transportFeatType.json";
    var transportLayerProps = [
    new mapfish.widgets.editing.StringProperty(
      {name: 'name', label: 'Name', showInGrid: true}),
    new mapfish.widgets.editing.ComboStringProperty(
      {name: 'feature_type', label: 'Feature Type', url: transportFeatTypeUrl, showInGrid: true}),
    new mapfish.widgets.editing.BooleanProperty(
      {name: 'crossing', label: 'Crossing (overhead)', showInGrid: true}), 
    new mapfish.widgets.editing.StringProperty(
      {name: 'comment', label: 'Comment', showInGrid: true}),
    new mapfish.widgets.editing.IntegerProperty(
      {name: 'user_id', showInGrid: false, extFieldCfg: {hidden: true, hideLabel: true}}),
    new mapfish.widgets.editing.IntegerProperty(
      {name: 'layer_id', showInGrid: false, extFieldCfg: {hidden: true, hideLabel: true}}),
    new mapfish.widgets.editing.StringProperty(
      {name: 'layer_year', showInGrid: false, extFieldCfg: {hidden: true, hideLabel: true}})
    ];



    var hydroFeatTypeUrl = jsPath + "dig/combo/hydroFeatType.json";
    var hydroLayerProps =  [
    new mapfish.widgets.editing.StringProperty(
      {name: 'name', label: 'Name', showInGrid: true}),
    new mapfish.widgets.editing.ComboStringProperty(
      {name: 'feature_type', label: 'Feature Type', url: hydroFeatTypeUrl, showInGrid: true}),
    new mapfish.widgets.editing.StringProperty(
      {name: 'comment', label: 'Comment', showInGrid: true}),
    new mapfish.widgets.editing.IntegerProperty(
      {name: 'user_id', showInGrid: false, extFieldCfg: {hidden: true, hideLabel: true}}),
    new mapfish.widgets.editing.IntegerProperty(
      {name: 'layer_id', showInGrid: false, extFieldCfg: {hidden: true, hideLabel: true}}),
    new mapfish.widgets.editing.StringProperty(
      {name: 'layer_year', showInGrid: false, extFieldCfg: {hidden: true, hideLabel: true}})
    ];


    function getUserFilter(){
      var userFilter = new OpenLayers.Filter.Comparison({
          type: OpenLayers.Filter.Comparison.EQUAL_TO,
          property: 'layer_id',
          value: refLayerID
        });
      return userFilter;
    }

    //NOTE do we want to hide some of these in the editor grid?
    //{name: 'BuildType', showInGrid: true, extFieldCfg: {disabled: true, hidden: true, hideLabel: true}})

    var layerConfig = {
      buildpolygons: {
        text: 'Buildings',
        projection: new OpenLayers.Projection("EPSG:4326"),
        filter: getUserFilter(),
        autoLoadLayer: 'true',
        protocol: new OpenLayers.Protocol.WFS({
            version: "1.1.0",
            srsName: "EPSG:4326",
            url: geoserverURL,
            featurePrefix: "nyplv",
            featureNS: "http://maps.nypl.org/v/gml/",
            featureType: "buildings",
            geometryName: "geom",
            projection: 'epsg:4326'
          }),
        featuretypes: {
          geometry: {
            type: OpenLayers.Geometry.Polygon
          },
          properties: buildLayerProps
        }
      },
      districtpolygons: {
        text: 'Districts',
        filter: getUserFilter(),
        autoLoadLayer: 'true',
        projection: new OpenLayers.Projection("EPSG:4326"),
        protocol: new OpenLayers.Protocol.WFS({
            version: "1.1.0",
            srsName: "EPSG:4326",
            url: geoserverURL,
            featurePrefix: "nyplv",
            featureNS: "http://maps.nypl.org/v/gml/",
            featureType: "districts",
            geometryName: "geom",
            projection: 'epsg:4326'
          }),
        featuretypes: {
          geometry: {
            type: OpenLayers.Geometry.Polygon
          },
          properties: districtLayerProps
        }
      },
      poipoints: {
        text: 'Points of Interest',
        filter: getUserFilter(),
        autoLoadLayer: 'true',
        projection: new OpenLayers.Projection("EPSG:4326"),
        protocol: new OpenLayers.Protocol.WFS({
            version: "1.1.0",
            srsName: "EPSG:4326",
            url: geoserverURL,
            featurePrefix: "nyplv",
            featureNS: "http://maps.nypl.org/v/gml/",
            featureType: "points_of_interest",
            geometryName: "geom",
            projection: 'epsg:4326'
          }),
        featuretypes: {
          geometry: {
            type: OpenLayers.Geometry.Point
          },
          properties: poiLayerProps
        }
      },
      transportlines: {
        text: 'Transport Network',
        filter: getUserFilter(),
        autoLoadLayer: 'true',
        projection: new OpenLayers.Projection("EPSG:4326"),
        protocol: new OpenLayers.Protocol.WFS({
            version: "1.1.0",
            srsName: "EPSG:4326",
            url: geoserverURL,
            featurePrefix: "nyplv",
            featureNS: "http://maps.nypl.org/v/gml/",
            featureType: "transport",
            geometryName: "geom",
            projection: 'epsg:4326'
          }),
        featuretypes: {
          geometry: {
            type: OpenLayers.Geometry.LineString
          },
          properties: transportLayerProps
        }
      },
      hydrolines: {
        text: 'Hydrography',
        filter: getUserFilter(),
        autoLoadLayer: 'true',
        projection: new OpenLayers.Projection("EPSG:4326"),
        protocol: new OpenLayers.Protocol.WFS({
            version: "1.1.0",
            srsName: "EPSG:4326",
            url: geoserverURL,
            featurePrefix: "nyplv",
            featureNS: "http://maps.nypl.org/v/gml/",
            featureType: "hydrography",
            geometryName: "geom",
            projection: 'epsg:4326'
          }),
        featuretypes: {
          geometry: {
            type: OpenLayers.Geometry.LineString
          },
          properties: hydroLayerProps
        }
      }

    };

    var fePanel = new mapfish.widgets.editing.FeatureEditingPanel({
        title: 'Edit and Add New Features',
        id: 'editing-panel',
        layerConfig: layerConfig,
        map: map,
        collapsible: true
      });

    //refLayerID layer_id and editingUser for user_id
    fePanel.on('afterfeatureadd', function(feature){

        feature.attributes.user_id = editingUser;
        fePanel.form.form.setValues([{id: 'user_id', value:editingUser}]);


        feature.attributes.layer_id = refLayerID ;
        fePanel.form.form.setValues([{id: 'layer_id', value:refLayerID}]);

        feature.attributes.layer_year = refLayerYear ;
        fePanel.form.form.setValues([{id: 'layer_year', value:refLayerYear}]);

        fePanel.updateFeatureAttributes(feature);
      });
    fePanel.on('beforecommit', function() {
        //console.log(fePanel);
      });
    digitizerPanel =  new Ext.Panel({
        renderTo: "dig-panel",
        height: 800,
        layout: 'border',
        listeners: {'afterlayout': {'fn': setupMap}},
        items: [
        {
          region: 'east',
          id: 'east-panel',
          width: 400,
          split: true,
          minSize: 200,
          maxSize: 900,
          autoScroll: true,
          items: [
          fePanel]
        }, 
        containingMapPanel                       
        ]
      });

    //set up a jquery slider (we use jquery sliders elsewhere for opacity changes)
    //digitizer-slider
    jQuery("#digitizer-slider").slider({
        value: 100,
        range: "min",
        slide: function(e, ui) {
          refLayer.setOpacity(ui.value / 100);
        }
      });
    jQuery("#digitizer-slider").show();
    refLayer.events.register('visibilitychanged', this, function(layer){
        if (layer.object.getVisibility() == true){
          jQuery("#digitizer-slider").show();
        } else {
          jQuery("#digitizer-slider").hide();
        }
      });


  });


function osm_getTileURL(bounds) {
  var res = this.map.getResolution();
  var x = Math.round((bounds.left - this.maxExtent.left) / (res * this.tileSize.w));
  var y = Math.round((this.maxExtent.top - bounds.top) / (res * this.tileSize.h));
  var z = this.map.getZoom();
  var limit = Math.pow(2, z);

  if (y < 0 || y >= limit) {
    return OpenLayers.Util.getImagesLocation() + "404.png";
  } else {
    x = ((x % limit) + limit) % limit;
    return this.url + z + "/" + x + "/" + y + "." + this.type;
  }
}


