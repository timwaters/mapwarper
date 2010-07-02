/* Copyright (C) 2008-2009 The Open Source Geospatial Foundation ¹
 * Published under the BSD license.
 * See http://geoext.org/svn/geoext/core/trunk/license.txt for the full text
 * of the license.
 * 
 * ¹ pending approval */

/**
 * @include GeoExt/data/LayerStore.js
 */

/** api: (define)
 *  module = GeoExt
 *  class = MapPanel
 *  base_link = `Ext.Panel <http://extjs.com/deploy/dev/docs/?class=Ext.Panel>`_
 */
Ext.namespace("GeoExt");

/** api: example
 *  Sample code to create a panel with a new map:
 * 
 *  .. code-block:: javascript
 *     
 *      var mapPanel = new GeoExt.MapPanel({
 *          border: false,
 *          renderTo: "div-id",
 *          map: {
 *              maxExtent: new OpenLayers.Bounds(-90, -45, 90, 45)
 *          }
 *      });
 *     
 *  Sample code to create a map panel with a bottom toolbar in a Window:
 * 
 *  .. code-block:: javascript
 * 
 *      var win = new Ext.Window({
 *          title: "My Map",
 *          items: [{
 *              xtype: "gx_mappanel",
 *              bbar: new Ext.Toolbar()
 *          }]
 *      });
 */

/** api: constructor
 *  .. class:: MapPanel(config)
 *   
 *      Create a panel container for a map.
 */
GeoExt.MapPanel = Ext.extend(Ext.Panel, {

    /** api: config[map]
     *  ``OpenLayers.Map or Object``  A configured map or a configuration object
     *  for the map constructor.  A configured map will be available after
     *  construction through the :attr:`map` property.
     */

    /** api: property[map]
     *  ``OpenLayers.Map``  A configured map object.
     */
    map: null,
    
    /** api: config[layers]
     *  ``GeoExt.data.LayerStore or GeoExt.data.GroupingStore or Array(OpenLayers.Layer)``
     *  A store holding records. If not provided, an empty
     *  :class:`GeoExt.data.LayerStore` will be created.
     */
    
    /** api: property[layers]
     *  :class:`GeoExt.data.LayerStore`  A store containing
     *  :class:`GeoExt.data.LayerRecord` objects.
     */
    layers: null,

    
    /** api: config[center]
     *  ``OpenLayers.LonLat or Array(Number)``  A location for the map center.  If
     *  an array is provided, the first two items should represent x & y coordinates.
     */
    center: null,

    /** api: config[zoom]
     *  ``Number``  An initial zoom level for the map.
     */
    zoom: null,

    /** api: config[extent]
     *  ``OpenLayers.Bounds or Array(Number)``  An initial extent for the map (used
     *  if center and zoom are not provided.  If an array, the first four items
     *  should be minx, miny, maxx, maxy.
     */
    extent: null,
    
    /** private: method[initComponent]
     *  Initializes the map panel. Creates an OpenLayers map if
     *  none was provided in the config options passed to the
     *  constructor.
     */
    initComponent: function(){
        if(!(this.map instanceof OpenLayers.Map)) {
            this.map = new OpenLayers.Map(
                Ext.applyIf(this.map || {}, {allOverlays: true})
            );
        }
        var layers = this.layers;
        if(!layers || layers instanceof Array) {
            this.layers = new GeoExt.data.LayerStore({
                layers: layers,
                map: this.map
            });
        }
        
        if(typeof this.center == "string") {
            this.center = OpenLayers.LonLat.fromString(this.center);
        } else if(this.center instanceof Array) {
            this.center = new OpenLayers.LonLat(this.center[0], this.center[1]);
        }
        if(typeof this.extent == "string") {
            this.extent = OpenLayers.Bounds.fromString(this.extent);
        } else if(this.extent instanceof Array) {
            this.extent = OpenLayers.Bounds.fromArray(this.extent);
        }
        
        GeoExt.MapPanel.superclass.initComponent.call(this);       
    },
    
    /** private: method[updateMapSize]
     *  Tell the map that it needs to recaculate its size and position.
     */
    updateMapSize: function() {
        if(this.map) {
            this.map.updateSize();
        }
    },
    
    /** private: method[onRender]
     *  Private method called after the panel has been
     *  rendered.
     */
    onRender: function() {
        GeoExt.MapPanel.superclass.onRender.apply(this, arguments);
        this.map.render(this.body.dom);
        if(this.map.layers.length > 0) {
            if(this.center) {
                // zoom does not have to be defined
                this.map.setCenter(this.center, this.zoom);
            }  else if(this.extent) {
                this.map.zoomToExtent(this.extent);
            } else {
                this.map.zoomToMaxExtent();
            }
        }
    },
    
    /** private: method[afterRender]
     *  Private method called after the panel has been rendered.
     */
    afterRender: function() {
        GeoExt.MapPanel.superclass.afterRender.apply(this, arguments);
        if(this.ownerCt) {
            this.ownerCt.on("move", this.updateMapSize, this);
        }
    },    

    /** private: method[onResize]
     *  Private method called after the panel has been resized.
     */
    onResize: function() {
        GeoExt.MapPanel.superclass.onResize.apply(this, arguments);
        this.updateMapSize();
    },
    
    /** private: method[onDestroy]
     *  Private method called during the destroy sequence.
     */
    onDestroy: function() {
        if(this.ownerCt) {
            this.ownerCt.un("move", this.updateMapSize, this);
        }
        GeoExt.MapPanel.superclass.onDestroy.apply(this, arguments);
    }
    
});

/** api: xtype = gx_mappanel */
Ext.reg('gx_mappanel', GeoExt.MapPanel); 
