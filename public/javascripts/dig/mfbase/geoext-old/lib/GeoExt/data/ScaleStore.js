/* Copyright (C) 2008-2009 The Open Source Geospatial Foundation ¹
 * Published under the BSD license.
 * See http://geoext.org/svn/geoext/core/trunk/license.txt for the full text
 * of the license.
 * 
 * ¹ pending approval */

Ext.namespace("GeoExt.data");

/**
 *  Class: GeoExt.data.ScaleStore
 *  This store maintains a list of available zoom levels, optionally keeping it synchronized with 
 *  a Map or MapPanel instance.   The entries in the list have the following fields: 
 *  zoom - the number of the zoom level
 *  scale - the scale denominator for the zoom level
 *  resolution - the map resolution when the zoom level is active.
 */
GeoExt.data.ScaleStore = Ext.extend(Ext.data.Store, {
    /**
     * Property: map
     * The OpenLayers.Map instance to which the store is bound, if any.
     */
    map: null,

    /**
     * Constructor: GeoExt.data.ScaleStore
     * Construct a ScaleStore from a configuration.  The ScaleStore accepts some custom parameters 
     * addition to the fields accepted by Ext.Store.
     * Additional options:
     * map - the GeoExt.MapPanel or OpenLayers.Map instance the store should stay sync'ed with
     */
    constructor: function(config) {
        var map = (config.map instanceof GeoExt.MapPanel ? config.map.map : config.map);
        delete config.map;
        config = Ext.applyIf(config, {reader: new Ext.data.JsonReader({}, [
            "level",
            "resolution",
            "scale"
        ])});

        GeoExt.data.ScaleStore.superclass.constructor.call(this, config);

        if (map) this.bind(map);
    },

    /**
     * APIMethod: bind
     * Bind this store to a map; that is, maintain the zoom list in sync with the map's current 
     * configuration.  If the map does not currently have a set scale list, then the store will 
     * remain empty until the map is configured with one.
     *
     * Parameters: 
     * map - the GeoExt.MapPanel or OpenLayers.Map to which we should bind
     * options - additional parameters for the bind operation (optional, currently unused)
     */
    bind: function(map, options) {
        this.map = (map instanceof GeoExt.MapPanel ? map.map : map);
        this.map.events.register('changebaselayer', this, this.populateFromMap);
        if (this.map.baseLayer) {
            this.populateFromMap();
        } else {
            this.map.register('layeradded', this, this.populateOnAdd);
        }
    },

    /**
     * APIMethod: unbind
     * Un-bind this store from the map to which it is currently bound.  The currently stored zoom 
     * levels will remain, but no further changes from the map will affect it.
     */
    unbind: function() {
        if (this.map) {
            this.map.events.unregister('changebaselayer', this, this.populateFromMap);
            delete this.map;
        }
    },

    /**
     * Method: populateOnAdd
     * This method handles the case where we have bind() called on a not-fully-configured map so 
     * that the zoom levels can be detected when a baselayer is finally added.
     *
     * Parameters:
     * evt - the OpenLayers event
     */
    populateOnAdd: function(evt) {
        if (evt.layer.isBaseLayer) {
            this.populateFromMap();
            this.map.events.unregister('layeradded', this, this.populateOnAdd);
        }
    },

    /**
     * Method: populateFromMap
     * This method actually loads the zoom level information from the OpenLayers.Map and converts 
     * it to Ext Records.
     */
    populateFromMap: function() {
        var zooms = [];

        for (var i = this.map.numZoomLevels-1; i > 0; i--) { 
            var res = this.map.getResolutionForZoom(i);
            var units = this.map.baseLayer.units;
            var scale = OpenLayers.Util.getScaleFromResolution(res, units);

            zooms.push({level: i, resolution: res, scale: scale});
        }

        this.loadData(zooms);
    }
});
