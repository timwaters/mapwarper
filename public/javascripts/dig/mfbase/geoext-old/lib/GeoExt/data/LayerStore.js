/* Copyright (C) 2008-2009 The Open Source Geospatial Foundation ¹
 * Published under the BSD license.
 * See http://geoext.org/svn/geoext/core/trunk/license.txt for the full text
 * of the license.
 * 
 * ¹ pending approval */

/**
 * @include GeoExt/data/LayerReader.js
 */

Ext.namespace("GeoExt.data");

/**
 * Class: GeoExt.data.LayerStoreMixin
 * A store that synchronizes a layers array of an {OpenLayers.Map} with a
 * layer store holding {<GeoExt.data.LayerRecord>} entries.
 * 
 * This class can not be instantiated directly. Instead, it is meant to extend
 * {Ext.data.Store} or a subclass of it:
 * (start code)
 * var store = new (Ext.extend(Ext.data.Store, GeoExt.data.LayerStoreMixin))({
 *     map: myMap,
 *     layers: myLayers
 * });
 * (end)
 * 
 * For convenience, a {<GeoExt.data.LayerStore>} class is available as a
 * shortcut to the Ext.extend sequence in the above code snippet. The above
 * is equivalent to:
 * (start code)
 * var store = new GeoExt.data.LayerStore({
 *     map: myMap,
 *     layers: myLayers
 * });
 * (end)
 */
GeoExt.data.LayerStoreMixin = {
    /**
     * APIProperty: map
     * {OpenLayers.Map} Map that this store will be in sync with.
     */
    map: null,

    /**
     * APIProperty: reader
     * {<GeoExt.data.LayerReader>} The reader used to get
     *     <GeoExt.data.LayerRecord> objects from {OpenLayers.Layer}
     *     objects.
     */
    reader: null,

    /**
     * Constructor: GeoExt.data.LayerStoreMixin
     * 
     * Parameters:
     * config - {Object}
     * 
     * Valid config options:
     * map - {OpenLayers.Map|<GeoExt.MapPanel>} map to sync the layer store
     *     with.
     * layers - {Array(OpenLayers.Layer)} Layers that will be added to the
     *     store (and the map, depending on the value of the initDir option).
     * fields - {Array} If provided a custom layer record type with additional
     *     fields will be used. Default fields for every layer record are
     *     {OpenLayers.Layer} layer and {String} title. The value of this
     *     option is either a field definition objects as passed to the
     *     GeoExt.data.LayerRecord.create function or a
     *     {<GeoExt.data.LayerRecord>} constructor created using
     *     GeoExt.data.LayerRecord.create.
     * initDir - {Number} Bitfields specifying the direction to use for the
     *     initial sync between the map and the store, if set to 0 then no
     *     initial sync is done. Defaults to
     *     <GeoExt.data.LayerStore.MAP_TO_STORE>|<GeoExt.data.LayerStore.STORE_TO_MAP>.
     */
    constructor: function(config) {
        config = config || {};
        config.reader = config.reader ||
                        new GeoExt.data.LayerReader({}, config.fields);
        delete config.fields;
        // "map" option
        var map = config.map instanceof GeoExt.MapPanel ?
                  config.map.map : config.map;
        delete config.map;
        // "layers" option - is an alias to "data" option
        if(config.layers) {
            config.data = config.layers;
        }
        delete config.layers;
        // "initDir" option
        var options = {initDir: config.initDir};
        delete config.initDir;
        arguments.callee.superclass.constructor.call(this, config);
        if(map) {
            this.bind(map, options);
        }
    },

    /**
     * APIMethod: bind
     * Bind this store to a map instance, once bound the store
     * is synchronized with the map and vice-versa.
     * 
     * Parameters:
     * map - {OpenLayers.Map} The map instance.
     * options - {Object}
     *
     * Valid config options:
     * initDir - {Number} Bitfields specifying the direction to use for the
     *     initial sync between the map and the store, if set to 0 then no
     *     initial sync is done. Defaults to
     *     <GeoExt.data.LayerStore.MAP_TO_STORE>|<GeoExt.data.LayerStore.STORE_TO_MAP>.
     */
    bind: function(map, options) {
        if(this.map) {
            // already bound
            return;
        }
        this.map = map;
        options = options || {};

        var initDir = options.initDir;
        if(options.initDir == undefined) {
            initDir = GeoExt.data.LayerStore.MAP_TO_STORE |
                      GeoExt.data.LayerStore.STORE_TO_MAP;
        }

        // create a snapshot of the map's layers
        var layers = map.layers.slice(0);

        if(initDir & GeoExt.data.LayerStore.STORE_TO_MAP) {
            var records = this.getRange();
            for(var i=records.length - 1; i>=0; i--) {
                this.map.addLayer(records[i].get("layer"));
            }
        }
        if(initDir & GeoExt.data.LayerStore.MAP_TO_STORE) {
            this.loadData(layers, true);
        }

        map.events.on({
            "changelayer": this.onChangeLayer,
            "addlayer": this.onAddLayer,
            "removelayer": this.onRemoveLayer,
            scope: this
        });
        this.on({
            "load": this.onLoad,
            "clear": this.onClear,
            "add": this.onAdd,
            "remove": this.onRemove,
            scope: this
        });
    },

    /**
     * APIMethod: unbind
     * Unbind this store from the map it is currently bound.
     */
    unbind: function() {
        if(this.map) {
            this.map.events.un({
                "changelayer": this.onChangeLayer,
                "addlayer": this.onAddLayer,
                "removelayer": this.onRemoveLayer,
                scope: this
            });
            this.un("load", this.onLoad, this);
            this.un("clear", this.onClear, this);
            this.un("add", this.onAdd, this);
            this.un("remove", this.onRemove, this);

            this.map = null;
        }
    },
    
    /**
     * Method: onChangeLayer
     * Handler for layer changes.  When layer order changes, this moves the
     *     appropriate record within the store.
     *
     * Parameters:
     * evt - {Object}
     */
    onChangeLayer: function(evt) {
        var layer = evt.layer;
        if(evt.property === "order") {
            if(!this._adding && !this._removing) {
                var layerIndex = this.map.getLayerIndex(layer);
                var recordIndex = this.findBy(function(rec, id) {
                    return rec.get("layer") === layer;
                });
                if(recordIndex > -1) {
                    if(layerIndex !== recordIndex) {
                        var record = this.getAt(recordIndex);
                        this._removing = true;
                        this.remove(record);
                        delete this._removing;
                        this._adding = true;
                        this.insert(layerIndex, [record]);
                        delete this._adding;
                    }
                }
            }
        }
    },
   
    /**
     * Method: onAddLayer
     * Handler for a map's addlayer event
     * 
     * Parameters:
     * evt - {Object}
     */
    onAddLayer: function(evt) {
        if(!this._adding) {
            var layer = evt.layer;
            this._adding = true;
            this.loadData([layer], true);
            delete this._adding;
        }
    },
    
    /**
     * Method: onRemoveLayer
     * Handler for a map's removelayer event
     * 
     * Parameters:
     * evt - {Object}
     */
    onRemoveLayer: function(evt){
        if(!this._removing) {
            var layer = evt.layer;
            this._removing = true;
            this.remove(this.getById(layer.id));
            delete this._removing;
        }
    },
    
    /**
     * Method: onLoad
     * Handler for a store's load event
     * 
     * Parameters:
     * store - {<Ext.data.Store>}
     * records - {Array(Ext.data.Record)}
     * options - {Object}
     */
    onLoad: function(store, records, options) {
        if (!Ext.isArray(records)) {
            records = [records];
        }
        if (options && !options.add) {
            this._removing = true;
            for (var i = this.map.layers.length - 1; i >= 0; i--) {
                this.map.removeLayer(this.map.layers[i]);
            }
            delete this._removing;

            // layers has already been added to map on "add" event
            var len = records.length;
            if (len > 0) {
                var layers = new Array(len);
                for (var j = 0; j < len; j++) {
                    layers[j] = records[j].get("layer");
                }
                this._adding = true;
                this.map.addLayers(layers);
                delete this._adding;
            }
        }
    },
    
    /**
     * Method: onClear
     * Handler for a store's clear event
     * 
     * Parameters:
     * store - {<Ext.data.Store>}
     */
    onClear: function(store) {
        this._removing = true;
        for (var i = this.map.layers.length - 1; i >= 0; i--) {
            this.map.removeLayer(this.map.layers[i]);
        }
        delete this._removing;
    },
    
    /**
     * Method: onAdd
     * Handler for a store's add event
     * 
     * Parameters:
     * store - {<Ext.data.Store>}
     * records - {Array(Ext.data.Record)}
     * index - {Number}
     */
    onAdd: function(store, records, index) {
        if(!this._adding) {
            this._adding = true;
            var layer;
            for(var i=records.length-1; i>=0; --i) {
                layer = records[i].get("layer");
                this.map.addLayer(layer);
                if(index !== this.map.layers.length-1) {
                    this.map.setLayerIndex(layer, index);
                }
            }
            delete this._adding;
        }
    },
    
    /**
     * Method: onRemove
     * Handler for a store's remove event
     * 
     * Parameters:
     * store - {<Ext.data.Store>}
     * records - {Array(Ext.data.Record)}
     * index - {Number}
     */
    onRemove: function(store, record, index){
        if(!this._removing) {
            var layer = record.get("layer");
            if (this.map.getLayer(layer.id) != null) {
                this._removing = true;
                this.map.removeLayer(record.get("layer"));
                delete this._removing;
            }
        }
    }
};

/**
 * Class: GeoExt.data.LayerStore
 * Default implementation of an {Ext.data.Store} extended with
 * {<GeoExt.data.LayerStoreMixin>}
 * 
 * Inherits from:
 * - {Ext.data.Store}
 * - {<GeoExt.data.LayerStoreMixin>}
 */
/**
 * Constructor: GeoExt.data.LayerStore
 * 
 * Parameters:
 * config - {Object} See {<GeoExt.data.LayerStoreMixin>} and 
 * http://extjs.com/deploy/dev/docs/?class=Ext.data.Store for valid config
 *     options. 
 */
GeoExt.data.LayerStore = Ext.extend(
    Ext.data.Store,
    GeoExt.data.LayerStoreMixin
);

/**
 * Constant: GeoExt.data.LayerStore.MAP_TO_STORE
 * {Integer} Constant used to make the store be automatically updated
 * when changes occur in the map.
 */
GeoExt.data.LayerStore.MAP_TO_STORE = 1;

/**
 * Constant: GeoExt.data.LayerStore.STORE_TO_MAP
 * {Integer} Constant used to make the map be automatically updated
 * when changes occur in the store.
 */
GeoExt.data.LayerStore.STORE_TO_MAP = 2;
