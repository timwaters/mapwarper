
/*
 * Copyright (C) 2009  Camptocamp
 *
 * This file is part of MapFish
 *
 * MapFish is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MapFish is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with MapFish.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @requires OpenLayers/Layer/Vector.js
 * @requires OpenLayers/Control/ModifyFeature.js
 * @requires OpenLayers/Strategy/BBOX.js
 * @requires core/Protocol/MapFish.js
 * @requires widgets/toolbar/Toolbar.js
 * @requires widgets/data/FeatureReader.js
 * @requires widgets/data/LayerStoreMediator.js
 * @requires widgets/editing/FeatureProperties.js
 */

Ext.namespace('mapfish.widgets', 'mapfish.widgets.editing');

/**
 * Class: mapfish.widgets.editing.FeatureEditingPanel
 * This class provides a panel for editing features.
 *
 * Inherits from:
 * - {Ext.Panel}
 */

/**
 * Constructor: mapfish.widgets.editing.FeatureEditingPanel
 *
 * Parameters:
 * config - {Object} Config object, see the possible Ext.Panel
 *     config options, and those specific to this panel
 *     documented below.
 */
mapfish.widgets.editing.FeatureEditingPanel = Ext.extend(Ext.Panel, {

    /**
     * Constant: COMBO_NONE_VALUE
     * The value of the none entry in the combo.
     */
    COMBO_NONE_VALUE: "__combo_none_value__",

    /**
     * Constant: COMBO_NONE_NAME
     * The name (label) of the none entry in the combo.
     */
    COMBO_NONE_NAME: OpenLayers.i18n("mf.editing.comboNoneName"),

    /**
     * APIProperty: map
     * {<OpenLayers.Map>} OpenLayers Map object.
     */
    map: null,

    /**
     * APIProperty: layerConfig
     * {Object} Hash of layers with config parameters.
     *
     * Example:
     * (code start)
     * {
     *     campfacilities: {
     *         text: "Camps",
     *         filter: new OpenLayers.Filter blah
     *         autoLoadLayer: "true", //loads layer upon selecting it in the combo box.
     *         protocol: new mapfish.Protocol.MapFish({url: "camps"}),
     *         featuretypes: {
     *             geometry: {
     *                 type: OpenLayers.Geometry.MultiPolygon
     *             },
     *             // See the documentation in the
     *             // mapfish.widgets.editing.FeatureProperties classes for more
     *             // details
     *             properties: [
     *                 new mapfish.widgets.editing.StringProperty(
     *                     {name: 'comment'}),
     *                 new mapfish.widgets.editing.IntegerProperty(
     *                     {name: 'status'}),
     *                 new mapfish.widgets.editing.ComboProperty(
     *                     {name: '_type', url: 'campfacilitytypes'}),
     *                 new mapfish.widgets.editing.IntegerProperty(
     *                     {name: 'name', showInGrid: true}),
     *                 new mapfish.widgets.editing.FloatProperty(
     *                     {name: 'camp_id'})
     *             ]
     *         }
     *     },
     *     refugees: {
     *         ...
     *     }
     * }
     * (end)
     */
    layerConfig: null,

    /**
     * Property: combo
     * {Ext.form.ComboBox} The combo box to select the layer to edit.
     */
    combo: null,

    /**
     * APIProperty: comboConfig
     * {Object} Optional config parameters for layer selection combo
     */
    comboConfig: null,

    /** NEW for all features store and grid
     */
    allStore: null,
    allGrid: null,
    layerAllStoreMediator: null,

    /**
     * Property: form
     * {Ext.FormPanel} The form to edit attributes.
     */
    form: null,

    /**
     * Property: store
     * {Ext.data.Store} The feature store for the grid.
     */
    store: null,

    /**
     * Property: layerStoreMediator
     * {<mapfish.widgets.data.LayerStoreMediator>} The layer store
     * mediator, it updates the store each time features are modified,
     * added to or removed from the layer.
     */
    layerStoreMediator: null,

    /**
     * Property: grid
     * {Ext.grid.GridPanel} The grid to store the edited features.
     */
    grid: null,

    /**
     * Property: menu
     * {Ext.menu.Menu} Context menu.
     */
    menu: null,

    /**
     * Property: layer
     * {<OpenLayers.Layer.Vector>} The vector layer.
     */
    layer: null,

    /**
     * Property: currentLayerId
     * {String} The identifier of the current edited layer.
     */
    currentLayerId: null,

    /**
     * Property: modifyControl
     * {<OpenLayers.Control.ModifyFeature>}  The modify feature
     * control.
     */
    modifyFeatureControl: null,

    /**
     * Property: drawFeatureControl
     * {<OpenLayers.Control.DrawFeature>} The draw feature control.
     */
    drawFeatureControl: null,

    /**
     * Property: importBtn
     * {Ext.Button} The import button.
     */
    importBtn: null,

    /**
     * Property: commitBtn
     * {Ext.Button} Rhe commit button.
     */
    commitBtn: null,

    /**
     * Property: deleteBtn
     * {Ext.Button} The delete button.
     */
    deleteBtn: null,

    /**
     * Property: attributesFormDefaults
     * {Ext.data.Record} A record representing default attributes
     * in the form.
     */
    attributesFormDefaults: null,

    /**
     * Method: initComponent
     * Initialize the component.
     */
    initComponent: function() {
        if (!this.map) {
            OpenLayers.Console.error(
                "map option for FeatureEditingPanel missing");
        }
        if (!this.layerConfig) {
            OpenLayers.Console.error(
                "layerConfig option for FeatureEditingPanel missing");
        }

        this.layout = 'form';
        this.tbar = this.createToolbar();

        mapfish.widgets.editing.FeatureEditingPanel.superclass.initComponent.apply(this);

        this.add(this.createLayerCombo());

        this.on("destroy", this.destroyResources, this);

        this.on("enable", this.setUp, this);
        this.on("disable", this.tearDown, this);

        // for accordion
        this.on('expand', this.setUp, this);
        this.on('e', this.tearDown, this);

        // for tabs
        this.on('activate', this.setUp, this);
        this.on('deactivate', this.tearDown, this);

        this.addEvents('beforecommit', 'commit', 'afterfeatureadd');
    },

    /**
     * Method: createToolbar
     * Create the toolbar with the editing tools.
     *
     * Returns:
     * {<mapfish.widgets.toolbar.Toolbar>} MapFish toolbar.
     */
    createToolbar: function() {
        this.importBtn = new Ext.Button({
            text: OpenLayers.i18n("mf.editing.import"),
            tooltip: OpenLayers.i18n("mf.editing.importTooltip"),
            disabled: true,
            handler: function() {
                this.refreshFeatures();
            },
            scope: this
        });
        this.commitBtn = new Ext.Button({
            text: OpenLayers.i18n("mf.editing.commit"),
            tooltip: OpenLayers.i18n("mf.editing.commitTooltip"),
            disabled: true,
            handler: function() {
                this.commitFeatures();
            },
            scope: this
        });
        this.deleteBtn = new Ext.Button({
            text: OpenLayers.i18n("mf.editing.delete"),
            tooltip: OpenLayers.i18n("mf.editing.deleteTooltip"),
            disabled: true,
            handler: function() {
                this.deleteFeatures();
            },
            scope: this
        });
        var buttons = [
            this.importBtn
        ,
            this.commitBtn
        , '-',
            this.deleteBtn
        ];
        return new mapfish.widgets.toolbar.Toolbar({
            items: buttons,
            map: this.map
        });
    },

    /**
     * Method: refreshFeatures
     * Refresh the vector layor.
     */
    refreshFeatures: function() {
        // we created the layer ourself so we're assured there's
        // only one strategy configured into it
        this.layer.strategies[0].update({force: true});
	
    },

    /**
     * Method: commitFeatures
     * Commit the modified features.
     */
    commitFeatures: function() {
        // callback func called on each update and create
        function onUpdateCreate(resp) {
            // if the modify feature control has a selected feature,
            // unselect it
            if (this.modifyFeatureControl.feature) {
                this.modifyFeatureControl.unselectFeature(
                    {feature: this.modifyFeatureControl.feature}
                );
            }
            var toDestroy = (resp.reqFeatures instanceof Array) ?
                            resp.reqFeatures : [resp.reqFeatures];
            
            this.layer.destroyFeatures(toDestroy);
           
	    //this.layer.addFeatures(resp.features);
            this.refreshFeatures();
		

            if (resp.last) {
                this.fireEvent("commit");
            }
        }
        // callback func called on each delete
        function onDelete(resp) {
            var features = resp.reqFeatures;
            if (!(features instanceof Array)) {
                features = [features];
            }
            this.layer.destroyFeatures(features);
            if (resp.last) {
                this.fireEvent("commit");
            }
        }
        this.fireEvent("beforecommit");

        var commitOptions = {
            scope: this, 
             callback: onUpdateCreate};


	  /*If the layer
     *     projection differs from the map projection, features will be
     *     transformed into the layer projection before being committed.*/
       
      var features = this.layer.features;

        var remote = this.layer.projection;
        var local = this.layer.map.getProjectionObject();
        if(!local.equals(remote)) {
            var len = features.length;
            var clones = new Array(len);
            var orig, clone;
            for(var i=0; i<len; ++i) {
                orig = features[i];
                clone = orig.clone();
                clone.fid = orig.fid;
                clone.state = orig.state;
                clone._original = orig;
                clone.geometry.transform(local, remote);
                clones[i] = clone;
            }
            features = clones;
        }
////////From Save.js ///

                this.layer.protocol.commit(features, commitOptions);
            
       
 //commented out as this is mapfish protocol specific     
//        this.layer.protocol.commit(this.layer.features, {
//            "create": {
//                scope: this,
//                callback: onUpdateCreate
//            },
//            "update": {
//                scope: this,
//                callback: onUpdateCreate
//            },
//            "delete": {
//                scope: this,
//                callback: onDelete
//            }
//        });
        
        
    },

    /**
     * Method: deleteFeatures
     * Delete the features that are in the selected features array of the layer.
     */
    deleteFeatures: function() {
        var feature;
        for (var i = this.layer.selectedFeatures.length - 1; i >= 0; i--) {
            feature = this.layer.selectedFeatures[i];
            // if the modify feature control has a selected feature,
            // and it is the current feature, unselect it
            if (this.modifyFeatureControl.feature == feature) {
                this.modifyFeatureControl.selectControl.unselect(feature);
            }
            if (feature.state == OpenLayers.State.INSERT) {
                // feature was created as part of the current "transaction",
                // so just destroy it right away
                this.layer.destroyFeatures([feature]);
            } else {
                feature.state = OpenLayers.State.DELETE;
                // add it to the store
                this.layerStoreMediator.featureStoreMediator.addFeatures(feature);
                //NEW for all
                this.layerAllStoreMediator.featureStoreMediator.addFeatures(feature);
                // and redraw it so it gets the proper styling
                this.layer.drawFeature(feature);
            }
        }
    },

    /**
     * Method: createLayerCombo
     * Create a combobox to let user choose the layer to edit.
     *
     * Returns:
     * {Ext.form.ComboxBox} A combobox
     */
    createLayerCombo: function() {
        var data = [[this.COMBO_NONE_VALUE, this.COMBO_NONE_NAME]];
        for (var i in this.layerConfig) {
            data.push([i, this.layerConfig[i].text]);
        }
        var store = new Ext.data.SimpleStore({
            fields: ['value', 'text'],
            data : data
        });
        var comboConfig = OpenLayers.Util.applyDefaults({
            fieldLabel: OpenLayers.i18n("mf.editing.comboLabel"),
            name: "editingLayer",
            hiddenName: "editingLayer",
            displayField: "text",
            valueField: "value",
            mode: "local",
            triggerAction: "all",
            editable: false,
            store: store,
            listeners: {
                select: function(combo, record, index) {
                    this.prepareSwitchLayer(record.data.value);
                },
                scope: this
            }
        }, this.comboConfig);
        this.combo = new Ext.form.ComboBox(comboConfig);
        return this.combo;
    },

    /**
     * Method: prepareSwitchLayer
     * Called when the user selects a layer in the combobox.
     *
     * Parameters:
     * id - {String} The layer id (key in layerConfig)
     */
    prepareSwitchLayer: function(id) {
        if (this.isDirty()) {
            Ext.Msg.confirm(
                OpenLayers.i18n("mf.editing.confirmMessageTitle"),
                OpenLayers.i18n("mf.editing.confirmMessage"),
                function(btn, text){
                    if (btn == "yes") {
                        this.switchLayer(id);
                    } else {
                        this.combo.setValue(this.currentLayerId);
                    }
                },
                this
            );
        } else {
            this.switchLayer(id);
        }
    },

    /**
     * Method: switchLayer
     *
     * Parameters:
     * id - {String} The layer id (key in layerConfig)
     */
    switchLayer: function(id) {
        if (id != this.COMBO_NONE_VALUE) {
            var config = this.layerConfig[id];
            this.configureLayer(config);
            this.createStore(config);
            this.createModifyFeatureControl();
            this.createDrawFeatureControl(config);
            this.createLayerStoreMediator();
            this.importBtn.enable();
            this.createForm(config);
            this.createGrid(config);
            //NEW for all
            this.createAllStore(config);
            this.createLayerAllStoreMediator();
            this.createAllGrid(config);
            if (config.autoLoadLayer && config.autoLoadLayer == "true"){
              this.refreshFeatures();
            }
        } else {
            this.destroyAllResources();
        }
        this.currentLayerId = id;
    },

    /**
     * Method: configureLayer
     *
     * Parameters:
     * config - {Object} The layer configuration.
     */
    configureLayer: function(config) {
        var layer = this.layer;
        if (!layer) {
            layer = this.layer = this.createLayer();
        }
        // we don't want to destroy the protocol when the layer
        // is destroyed
        config.protocol.autoDestroy = false;
        layer.protocol = config.protocol;
        layer.filter = config.filter;
        if (OpenLayers.Util.indexOf(this.map.layers, layer) < 0) {
            this.map.addLayer(layer);
        }
        layer.destroyFeatures();
    },

    /**
     * Method: createLayer
     * Create the vector layer.
     */
    createLayer: function() {
      
     
        var layer = new OpenLayers.Layer.Vector(
            OpenLayers.Util.createUniqueID("Editing Layer_"), {
            strategies: [this.createStrategy()],
            styleMap: this.createStyleMap(),
	    projection: new OpenLayers.Projection("EPSG:4326"),
            displayInLayerSwitcher: true
        });
        layer.events.register(
            "featureselected", this, this.onFeatureselected
        );
        layer.events.register(
            "featureunselected", this, this.onFeatureunselected
        );
        layer.events.register(
            "featureremoved", this, this.onFeatureremoved
         );
        layer.events.register(
            "featuremodified", this, this.onFeaturemodified
        );
        return layer;
    },

    /**
     * Method: destroyLayer
     * Destroy the vector layer.
     */
    destroyLayer: function() {
        var layer = this.layer;
        if (layer) {
            layer.destroy();
            this.layer = null;
        }
    },

    /**
     * Method: createStyleMap
     * Create a style map for the vector layer.
     *
     * Returns:
     * {<OpenLayer.StyleMap>} The style map.
     */
    createStyleMap: function() {
        var lineSymboliser = {
          "Line": {strokeWidth: 2}
        };
        var style = new OpenLayers.Style();
        style.addRules(new OpenLayers.Rule({symbolizer: lineSymboliser}));
        var styleMap = new OpenLayers.StyleMap({"default":style});
        // create a styleMap for the vector layer so that features
        // have different styles depending on their state
        var context = function(feature) {
            return {
                state: feature.state || OpenLayers.State.UNKNOWN
            };
        };
        var lookup = {};
        lookup[OpenLayers.State.UNKNOWN] = {
        };
        lookup[OpenLayers.State.UPDATE] = {
            fillColor: "green",
            strokeColor: "green"
        };
        lookup[OpenLayers.State.DELETE] = {
            fillColor: "red",
            strokeColor: "red",
            fillOpacity: 0.2,
            strokeOpacity: 0.3,
            display: ""
        };
        lookup[OpenLayers.State.INSERT] = {
            fillColor: "green",
            strokeColor: "green"
        };
        styleMap.addUniqueValueRules("default", "state", lookup, context);
        styleMap.addUniqueValueRules("delete", "state", lookup, context);
        return styleMap;
    },



    /**
     * Method: createStrategy
     * Create a BBOX strategy for the vector layer.
     *
     * Returns:
     * {<OpenLayers.Strategy.BBOX>}
     */
    createStrategy: function() {
        return new OpenLayers.Strategy.BBOX({
            autoActivate: false
        });
    },

    /**
     * Method: onFeatureselected
     *
     * Parameters:
     * obj - {Object} Object with a feature property
     */
    onFeatureselected: function(obj) {
        var f = obj.feature;
        this.deleteBtn.enable();
        this.selectInGrid(f);
        this.editAttributes(f);
    },

    /**
     * Method: onFeatureunselected
     *
     * Parameters:
     * obj - {Object} Object with a feature property
     */
    onFeatureunselected: function(obj) {
        this.deleteBtn.disable();
        this.unselectInGrid();
        this.form.getForm().reset();
        this.form.setDisabled(true);
    },

    /**
     * Method: createStore
     * Create the store containing the edited features.
     */
    createStore: function(config) {
        this.destroyStore();
        var fields = [];
        var properties = config.featuretypes.properties;
        for (var i = 0; i < properties.length; i++) {
            fields.push(properties[i].getRecordType());
        }
        var store = new Ext.data.GroupingStore({
            reader: new mapfish.widgets.data.FeatureReader(
                {}, fields
            ),
            groupField: "state"
        });
        store.on("add", this.updateCommitBtnState, this);
        store.on("remove", this.updateCommitBtnState, this);
        store.on("clear", this.updateCommitBtnState, this);
        store.on("load", this.updateGridSelection, this);
        this.store = store;
    },

    /**
     * Method: destroyStore
     * Destroy the feature store.
     */
    destroyStore: function() {
        var store = this.store;
        if (store) {
            // for unknown reason this method is in Ext's API
            // doc, use it anyway as it's the safest method to
            // unregister listeners registered in the store
            store.destroy();
            this.store = null;
        }
    },

    /**
     * Method: updateCommitBtnState
     * Enable or disable the commit button based on whether there
     * are records or store in the store.
     */
    updateCommitBtnState: function(store) {
        this.commitBtn.setDisabled(!(store.getCount() > 0));
    },

    /**
     * Method: updateGridSelection
     * Make the selection in the grid reflect what's selected in
     * the layer.
     */
    updateGridSelection: function(store, records, options) {
        for (var i = 0; i < records.length; i++) {
            var feature = records[i].data.feature;
            if (OpenLayers.Util.indexOf(
                    this.layer.selectedFeatures, feature) >= 0) {
                this.selectInGrid(feature);
            }
        }
    },

    /**
     * Method: createModifyFeatureControl
     * Create a modify feature control.
     */
    createModifyFeatureControl: function() {
        this.destroyModifyFeatureControl();
        var ctrl = new OpenLayers.Control.ModifyFeature(this.layer, {
            mode: OpenLayers.Control.ModifyFeature.RESHAPE |
                  OpenLayers.Control.ModifyFeature.DRAG,
            title: OpenLayers.i18n("mf.editing.selectModifyFeature")
        });
        this.getTopToolbar().addControl(ctrl, {
            iconCls: 'modifyfeature',
            toggleGroup: this.getId() + 'map'
        });
        ctrl.activate();
        this.modifyFeatureControl = ctrl;
        snap = new OpenLayers.Control.Snapping({layer: this.layer});
        this.map.addControl(snap);
        snap.activate();
      },

    /**
     * Method: destroyModifyFeatureControl
     * Destroy the modify feature control.
     */
    destroyModifyFeatureControl: function() {
        var ctrl = this.modifyFeatureControl;
        if (ctrl) {
            this.getTopToolbar().removeControl(ctrl);
            ctrl.destroy();
            this.modifyFeatureControl = null;
        }
    },

    /**
     * Method: onFeatureremoved
     *
     * Parameters:
     * obj - {Object} Object with a feature property
     */
    onFeatureremoved: function(obj) {
        if (this.modifyFeatureControl &&
            obj.feature == this.modifyFeatureControl.feature) {
            this.modifyFeatureControl.feature = null;
        }
    },

    /**
     * Method: onFeaturemodified
     *
     * Parameters:
     * obj - {Object} Object with a feature property
     */
     onFeaturemodified: function(obj) {
         var feature = obj.feature;
         if (feature.state != OpenLayers.State.INSERT) {
             feature.state = OpenLayers.State.UPDATE;
         }
     },

    /**
     * Method: createDrawFeatureControl
     * Create a modify feature control.
     *
     * Parameters:
     * config -  {Object} A layer config object.
     */
    createDrawFeatureControl: function(config) {
        this.destroyDrawFeatureControl();
        var title, handler, multi = false, iconCls;
        switch (config.featuretypes.geometry.type) {
            case OpenLayers.Geometry.MultiPoint:
                multi = true;
            case OpenLayers.Geometry.Point:
                title = OpenLayers.i18n("mf.editing.drawPointTitle");
                handler = OpenLayers.Handler.Point;
                iconCls = "drawpoint";
                break;
            case OpenLayers.Geometry.MultiPolygon:
                multi = true;
            case OpenLayers.Geometry.Polygon:
                title = OpenLayers.i18n("mf.editing.drawPolygonTitle");
                handler = OpenLayers.Handler.Polygon;
                iconCls = "drawpolygon";
                break;
            case OpenLayers.Geometry.MultiLineString:
                multi = true;
            case OpenLayers.Geometry.LineString:
                title = OpenLayers.i18n("mf.editing.drawLineTitle");
                handler = OpenLayers.Handler.Path;
                iconCls = "drawline";
                break;
        }
        var ctrl =  new OpenLayers.Control.DrawFeature(this.layer, handler, {
            title: title,
            featureAdded: OpenLayers.Function.bind(this.onFeatureadded, this),
            handlerOptions: {
                multi: multi
            }
        });
        this.getTopToolbar().addControl(ctrl, {
            iconCls: iconCls,
            toggleGroup: this.getId() + 'map'
        });
        this.drawFeatureControl = ctrl;
    },

    /**
     * Method: destroyDrawFeatureControl
     * Destroy the draw feature control.
     */
    destroyDrawFeatureControl: function() {
        var ctrl = this.drawFeatureControl;
        if (ctrl) {
            this.getTopToolbar().removeControl(ctrl);
            ctrl.destroy();
            this.drawFeatureControl = null;
        }
    },

    /**
     * Method: onFeatureadded
     *
     * Parameters:
     * feature - {<OpenLayers.Feature.Vector>}
     */
    onFeatureadded: function(feature) {
        feature.state = OpenLayers.State.INSERT;
        // HACK: at this point "featuresadded" has alreay been triggered,
        // so for the layer store mediator to see the INSERT state of
        // that feature we trigger "featuresadded" again
        this.layer.events.triggerEvent("featuresadded", {
            features: [feature]
        });
        this.modifyFeatureControl.selectControl.select(feature);
        this.form.getForm().loadRecord(
            this.attributesFormDefaults
        );
        this.modifyFeatureControl.activate();
	this.fireEvent("afterfeatureadd", feature);
    },

    /**
     * Method: createLayerStoreMediator
     * Create the layer store mediator.
     */
    createLayerStoreMediator: function() {
        this.destroyLayerStoreMediator();
        var lsm = new mapfish.widgets.data.LayerStoreMediator({
            store: this.store,
            layer: this.layer,
            filter: function(feature) {
                return feature.state != null &&
                       feature.state != OpenLayers.State.UNKNOWN;
            }
        });
        lsm.activate();
        this.layerStoreMediator = lsm;
    },

    /**
     * Method: destroyLayerStoreMediator
     * Destroy the layer store mediator.
     */
    destroyLayerStoreMediator: function() {
        var lsm = this.layerStoreMediator;
        if (lsm) {
            lsm.deactivate();
            this.layerStoreMediator = null;
        }
    },

    /**
     * Method: destroyAllResources
     * Called when "None" is select in the combo.
     */
    destroyAllResources: function() {
        this.destroyResources();
        this.destroyForm();
        this.destroyGrid();

        this.destroyAllGrid(); //new for all
    },

    /**
     * Method: destroyResources
     * Called when the feature editing panel is destroyed, takes care
     * of destroying all the resources that aren't destroyed by the
     * Ext.Panel destroy method.
     */
    destroyResources: function() {
        // note: the components that are actually added to the feature
        // editing panel are destroyed in the destroy method of
        // Ext.Panel
        this.destroyStore();
        this.destroyModifyFeatureControl();
        this.destroyDrawFeatureControl();
        this.destroyLayerStoreMediator();
        this.destroyLayer();
   
        this.destroyAllStore();
        this.destroyLayerAllStoreMediator();//new all
      },

    /**
     * Method: setUp
     * Set up the feature editing panel.
     */
    setUp: function() {
        if (this.layer &&
            this.currentLayerId != this.COMBO_NONE_VALUE) {
            this.map.addLayer(this.layer)
        }
        if (this.modifyFeatureControl) {
            this.modifyFeatureControl.activate();
        }
    },

    /**
     * Method: tearDown
     * Tear down the feature editing panel.
     */
    tearDown: function() {
        if (this.modifyFeatureControl) {
            this.modifyFeatureControl.deactivate();
        }
        if (this.drawFeatureControl) {
            this.drawFeatureControl.deactivate();
        }
        var layer = this.layer;
        if (layer &&
            OpenLayers.Util.indexOf(this.map.layers, layer) >= 0) {
            this.map.removeLayer(layer)
        }
    },

    /**
     * Method: createForm
     * Create the feature attributes form for a given layer.
     *
     * Parameters:
     * config - {Object} The layer config object.
     */
    createForm: function(config) {
        if (!config.featuretypes) {
            OpenLayers.Console.error(
                "no featuretypes exist for the given layer"
            );
            return;
        }
        var form = this.form;
        if (!form) {
            var form = new Ext.FormPanel({
                title: OpenLayers.i18n("mf.editing.formTitle"),
                disabled: true,
					collapsible: true,
                items: [{}], // hack to avoid JS errors if no items are provided
                trackResetOnLoad: true, // to detect attributes updates
                bodyStyle: 'padding: 5px',
                buttons: [{
                    text: 'Save Attributes',
                    handler: function() {
                        if (!this.currentlyEditedFeature ||
                            !this.form.getForm().isDirty()) {
                            return;
                        }
                        this.updateFeatureAttributes(this.currentlyEditedFeature);
                        this.modifyFeatureControl.deactivate();
                        this.drawFeatureControl.activate(); 
                        },

                    scope: this
                }]
            });
            this.add(form);
            this.form = form;
            this.doLayout();
        }
        // clear current form (remove all items)
        var items = this.form.items.items
        for (var i = items.length - 1; i >=0; --i) {
            var field = items[i];
            form.getForm().remove(field);
            form.remove(field);
        }
        var properties = config.featuretypes.properties;
        var defaults = {};
        for (i = 0; i < properties.length; i++) {
            var property = properties[i];
            form.add(property.getExtField());
            defaults[property.name] = property.defaultValue;
        }
        form.doLayout();
        this.attributesFormDefaults = new Ext.data.Record(defaults);
        form.getForm().loadRecord(this.attributesFormDefaults);
    },

    /**
     * Method: destroyForm
     * Destroy the feature attributes form.
     */
    destroyForm: function() {
        var form = this.form;
        if (form) {
            form.destroy();
            this.form = null;
        }
    },

    /**
     * Method: updateFeatureAttributes
     * Loops into the attributes form and updates the OL feature
     *     attributes and data properties
     *
     * Parameters:
     * feature - {<OpenLayers.Feature>} The feature whose attributes are
     *     to be updated
     */
    updateFeatureAttributes: function(feature) {
        var item, value, i, items = this.form.items.items;
        for (i = 0; i < items.length; i++) {
            item = items[i];
            if (!item.getValue) {
                // prevent errors if this is not a form field
                continue;
            }
            if (item.isDirty && item.isDirty()) {
                value = item.getValue();
                feature.attributes[item.name] = value;
                feature.data[item.name] = value;
            }
        }
        if (feature.state != OpenLayers.State.INSERT) {
            feature.state = OpenLayers.State.UPDATE;
        }
        var fsm = this.layerStoreMediator.featureStoreMediator;
        fsm.addFeatures([feature]);
        var fasm = this.layerAllStoreMediator.featureStoreMediator; //new for all store
    //TODO FIX    fasm.addFeatures([feature]);
    },

    /**
     * Method: createGrud
     * Create a feature grid for the given layer.
     *
     * Parameters:
     * config - {Object} Layer config object.
     */
    createGrid: function(config) {
        var grid = this.grid;
        if (grid) {
            this.destroyGrid();
        }
        if (!config.featuretypes) {
            OpenLayers.Console.error(
                "no featuretypes exist for the given layer");
            return;
        }
        if (!config.featuretypes.properties) {
            OpenLayers.Console.error(
                "no featuretypes properties are given for layer");
            return;
        }
        var columns = [{
            header: OpenLayers.i18n("mf.editing.gridIdHeader"),
            dataIndex: "fid"
        }];
        Ext.each(config.featuretypes.properties, function(property) {
            if (property.showInGrid) {
                columns.push({
                    // FIXME it should use i18n instead of using the text property
                    header: property.label || property.name,
                    dataIndex: property.name
                });
            }
        });
        columns.push({
            header: OpenLayers.i18n("mf.editing.gridStateHeader"),
            dataIndex: "state"
        });
        grid = new Ext.grid.GridPanel({
            title: OpenLayers.i18n("Changed Features"),
            height: 170,
	    //autoHeight: true,
            collapsible: true, //NOTE collapsible:  false was default 
            store: this.store,
            view: new Ext.grid.GroupingView({
                groupTextTpl: '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "Features" : "Feature"]})'
            }),
            columns: columns
        });
        grid.on("rowcontextmenu", this.onContextClick, this);
        this.add(grid);
        this.doLayout();
        this.grid = grid;
    },

    /**
     * Method: destroyGrid
     * Destroy the feature grid.
     */
    destroyGrid: function() {
        if (this.grid) {
            this.grid.destroy();
            this.grid = null;
        }
    },

    /**
     * Method: selectInGrid
     * Selects and focuses on the row of a given feature in the featureGrid
     *
     * Parameters:
     * feature - {<OpenLayers.Feature>}
     */
    selectInGrid: function(feature) {
        if (this.store && this.grid) {
            var index = this.store.findBy(function(rec, id) {
                return rec.get("feature") == feature;
            });
            var record = this.store.getAt(index);
            this.grid.getSelectionModel().selectRecords([record]);
            if (index != -1) {
                this.grid.getView().focusRow(index);
            }
        }
    },

    /**
     * Method: unselectInGrid
     */
    unselectInGrid: function() {
        if (this.grid) {
            this.grid.getSelectionModel().clearSelections();
        }
    },

    /**
     * Method: editAttributes
     * Shows/enable the editing attributes form and loads the
     *     feature attributes in the corresponding fields
     *
     * Parameters
     * feature - {<OpenLayers.Feature.Vector>}
     */
    editAttributes: function(feature) {
        this.currentlyEditedFeature = feature;
        this.form.getForm().reset();

        // use the feature store read to get a record object corresponding
        // to the edited feature
        var obj = this.store.reader.readRecords([feature]);
        var record = obj.records[0];

        this.form.getForm().loadRecord(record);
        this.form.enable();
    },

    /**
     * Method: onContextClick
     * Is called when user right clicks on a feature grid row
     *     Shows a contextual menu
     *
     * Parameters
     * grid - {<Ext.grid.GridPanel>}
     * index - {<Ext.Record>}
     * e - {<Ext.Event>}
     */
    onContextClick: function(grid, index, e) {
        var menu = this.menu;
        if (!menu) { // create context menu on first right click
            menu = new Ext.menu.Menu({
                id: 'grid-ctx',
                items: [{
                    text: OpenLayers.i18n('mf.editing.onContextClickMessage'),
                    scope: this,
                    handler: function() {
                        this.modifyFeatureControl.selectControl.unselectAll();
                        var feature = this.ctxRecord.data.feature;
                        this.modifyFeatureControl.selectControl.select(feature);
                        this.modifyFeatureControl.activate();
                    }
                }]
            });
            menu.on('hide', this.onContextHide, this);
            this.menu = menu;
        }
        e.stopEvent();
        if (this.ctxRow) {
            Ext.fly(this.ctxRow).removeClass('x-node-ctx');
            this.ctxRow = null;
        }
        this.ctxRow = grid.view.getRow(index);
        this.ctxRecord = grid.store.getAt(index);
        Ext.fly(this.ctxRow).addClass('x-node-ctx');
        menu.showAt(e.getXY());
    },

    /**
     * Method: onContextHide
     * Hides the context menu
     */
    onContextHide : function(){
        if(this.ctxRow) {
            Ext.fly(this.ctxRow).removeClass('x-node-ctx');
            this.ctxRow = null;
        }
    },

    /**
     * Method: isDirty
     * Checks for unsaved (uncommited) changes
     *
     * Returns
     * {Boolean} - true is there are no unsaved changes
     */
    isDirty: function() {
        return (this.store &&
                this.store.getCount() > 0);
    },

    /**
     * APIMethod: setWindowOnbeforeunload
     * Convenience method that sets window.onbeforeunload so that
     * when going away from the page a confirm window is displayed
     * if the store includes uncommitted changes.
     */
    setWindowOnbeforeunload: function() {
        window.onbeforeunload = OpenLayers.Function.bind(
            function(e) {
                if (this.isDirty()) {
                    return OpenLayers.i18n("mf.editing.onBeforeUnloadMessage");
                }
            },
            this
        );
    },


/** Number of new functions to set up a grid and store to keep all features in **/
    createAllStore: function(config) {
                  this.destroyAllStore();
                  var fields = [];
                  var properties = config.featuretypes.properties;
                  for (var i = 0; i < properties.length; i++) {
                    fields.push(properties[i].getRecordType());
                  }
                  var store = new Ext.data.GroupingStore({
        reader: new mapfish.widgets.data.FeatureReader(
          {}, fields
          ),groupField: "state"});

                  store.on("add", this.updateCommitBtnState, this);
                  store.on("remove", this.updateCommitBtnState, this);
                  store.on("clear", this.updateCommitBtnState, this);
                  store.on("load", this.updateGridSelection, this);
                  this.allStore = store;
    },

    destroyAllStore: function() {
                   var store = this.allStore;
                   if (store) {
                     // for unknown reason this method is in Ext's API
                     // doc, use it anyway as it's the safest method to
                     // unregister listeners registered in the store
                     store.destroy();
                     this.allStore = null;
                   }
    },

    createLayerAllStoreMediator: function() {
                    this.destroyLayerAllStoreMediator();
                    var lsm = new mapfish.widgets.data.LayerStoreMediator({
                      store: this.allStore,
                      layer: this.layer,
                      filter: function(feature) {
                      return  feature.state != OpenLayers.State.UNKNOWN && !feature._sketch;}
                      });
                    lsm.activate();
                    this.layerAllStoreMediator = lsm;
    },
     /**
      *       Method: destroyLayerStoreMediator
      *       Destroy the layer store mediator.
      */
    destroyLayerAllStoreMediator: function() {
                                var lsm = this.layerAllStoreMediator;
                                if (lsm) {
                                  lsm.deactivate();
                                  this.layerAllStoreMediator = null;
                                }
                              },

    createAllGrid: function(config) {
                 var grid = this.allGrid;
                 if (grid) {
                   this.destroyAllGrid();
                 }
                 if (!config.featuretypes) {
                   OpenLayers.Console.error(
                       "no featuretypes exist for the given layer");
                   return;
                 }
                 if (!config.featuretypes.properties) {
                   OpenLayers.Console.error(
                       "no featuretypes properties are given for layer");
                   return;
                 }
                 var columns = [{
          header: OpenLayers.i18n("mf.editing.gridIdHeader"),
          dataIndex: "fid"
                 }];
                 Ext.each(config.featuretypes.properties, function(property) {
                     if (property.showInGrid) {
                     columns.push({header: property.label || property.name,
                       dataIndex: property.name,
                       sortable: true
                       });
                     }
                     });
                 columns.push({header: OpenLayers.i18n("mf.editing.gridStateHeader"),
                     dataIndex: "state",
                     sortable: true
                     });
                 grid = new Ext.grid.GridPanel({title: OpenLayers.i18n("Features List"),
                     autoHeight: true,
                     collapsible: true, //NOTE collapsible:  false was default 
                     store: this.allStore,
                     view: new Ext.grid.GridView({groupTextTpl:
                       '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "Features" : "Feature"]})'
                       }),
                    columns: columns
              });
                 grid.on("rowcontextmenu", this.onContextClick, this);
                 this.add(grid);
                 this.doLayout();
                 this.allGrid = grid;
          },

          /**
          *       Method: destroyGrid
          *            Destroy the feature grid.
          *           
          */
      destroyAllGrid: function() {
                  if (this.allGrid) {
                    this.allGrid.destroy();
                    this.allGrid = null;
                  }
      }

});

Ext.reg('featureediting', mapfish.widgets.editing.FeatureEditingPanel);
