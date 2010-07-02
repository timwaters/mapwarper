/*
 * Copyright (C) 2007-2008  Camptocamp
 *
 * This file is part of MapFish Client
 *
 * MapFish Client is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MapFish Client is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MapFish Client.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @requires OpenLayers/Map.js
 * @requires OpenLayers/BaseTypes/LonLat.js
 * @requires OpenLayers/Layer/Vector.js
 * @requires OpenLayers/Feature/Vector.js
 * @requires OpenLayers/Geometry/Point.js
 * @requires OpenLayers/StyleMap.js
 * @requires widgets/ComboBoxFactory.js
 */

Ext.namespace('mapfish.widgets', 'mapfish.widgets.recenter');

/**
 * Class: mapfish.widgets.recenter.Base
 * Base class for various recentering tools. Must be extendaded in specific classes.
 *
 * Inherits from:
 * - {Ext.FormPanel}
 */

/**
 * Constructor: mapfish.widgets.recenter.Base
 *
 * Parameters:
 * config - {Object} The config object
 * Returns:
 * {<mapfish.widgets.recenter.Base>}
 */
mapfish.widgets.recenter.Base = function(config) {
    Ext.apply(this, config);
    mapfish.widgets.recenter.Base.superclass.constructor.call(this);
};

Ext.extend(mapfish.widgets.recenter.Base, Ext.FormPanel, {

    /**
     * APIProperty: scales
     * {Array} - List of available scales
     */
    scales: null,

    /**
     * APIProperty: showCenter
     * {Boolean} - Indicates if a symbol must be shown at the new center
     */
    showCenter: null,

    /**
     * APIProperty: defaultZoom
     * {Integer} - Zoom level used if no zoom level is provided by the user
     */
    defaultZoom: null,

    /**
     * Property: vectorLayer
     * {<OpenLayers.Layer.Vector>} - Vector layer used to display a symbol
     *                               on new center point
     */
    vectorLayer: null,

    /**
     * Property: expandedOnce
     * {Boolean} - has already been expanded (don't call addItems twice)
     */
    expandedOnce: false,

    /**
     * Method: initComponent
     * Overrides super-class initComponent method. Builds the recentering form.
     */
    initComponent: function() {

        mapfish.widgets.recenter.Base.superclass.initComponent.apply(this, arguments);

        this.on("destroy", this.destroyResources, this);
        this.on("collapse", this.destroyResources, this);
        this.on("deactivate", this.destroyResources, this);
        this.on("disable", this.destroyResources, this);
    },

    /**
     * Method: render
     */
    render: function() {
        // if container layout is accordion we defer items adding
        // to avoid rendering issues (on comboboxes in particular)
        if (!this.ownerCt || !this.ownerCt.initialConfig.layout ||
            this.ownerCt.initialConfig.layout.toLowerCase != 'accordion') {
            this.addItems();
        }
        
        mapfish.widgets.recenter.Base.superclass.render.apply(this, arguments);
    },

    /**
     * Method: expand
     */
    expand: function() {
        mapfish.widgets.recenter.Base.superclass.expand.apply(this, arguments);
        if (!this.expandedOnce) {
            this.addItems();
            this.expandedOnce = true;
            this.doLayout();
        }
    },

    /**
     * Method: addItems
     * 
     * Adds the items.
     *
     * Usefull to defer add items when container layout is accordion
     * Called either by addItems or expand
     */
    addItems: function() {
        OpenLayers.Console.warn("must be implemented by subclasses");
    },

    /**
     * Method: removeAll
     * Removes all items from both formpanel and basic form
     */
    removeAll:function() {
        if (this.items) {
            // remove form panel items
            this.items.each(this.remove, this);
            // remove basic form items
            this.form.items.clear();
        }
    },

    /**
     * Method: addRecenterButton
     */
    addRecenterButton: function() {
        this.addButton({
            text: OpenLayers.i18n('mf.recenter.submit'),
            handler: this.recenter,
            scope: this
        });
    },

    /**
     * Method: addScaleCombo
     *
     * Adds a scale combobox in the form
     */
    addScaleCombo: function() {

        this.add(
            mapfish.widgets.createScaleComboBox(
                {
                    scales: this.scales
                },
                {
                    fieldLabel: OpenLayers.i18n('mf.print.scale'),
                    typeAhead: false,
                    value: this.scales[this.defaultZoom] || this.scales[0],
                    mode: 'local',
                    id: 'scale_' + this.getId(),
                    name: "scale",
                    hiddenName: 'scaleValue',
                    editable: false,
                    triggerAction: 'all'
                }
            )
        );
        // TODO: update default selected scale when zooming or only
        // when form is shown (may depend on parent containers status)
    },

    /**
     * Method: recenter
     * Recentering action. Implemented by child classes.
     */
    recenter: function() {
        OpenLayers.Console.warn("must be implemented by subclasses");
    },

    /**
     * Method: recenterOnCoords
     * Recenters on given coordinates and zoom level
     *
     * Parameters:
     * x - {Float} easting coordinate
     * y - {Float} northing coordinate
     * zoom - {Integer} zoom level (optional)
     */
    recenterOnCoords: function(x, y, zoom) {
        
        // use default zoom level if provided in widget config, 
        // else keep current zoom level
        if (typeof(zoom) == 'undefined') {
            zoom = (typeof(this.defaultZoom) != 'undefined') 
                   ? this.defaultZoom : this.map.getZoom()
        }

        if (this.showCenter) {
            // display a symbol on the new center point
            this.showCenterMark(x, y);
        }

        this.map.setCenter(new OpenLayers.LonLat(x, y), zoom);
    },

    /** 
     * Method: recenterOnBbox 
     * Recenters on given bounds 
     * 
     * Parameters: 
     * bbox - {<OpenLayers.Bounds>} 
     */ 
    recenterOnBbox: function(bbox) { 
        if (this.showCenter) { 
            // display a symbol on the center point of the bbox 
            var lonlat = bbox.getCenterLonLat(); 
            this.showCenterMark(lonlat.lon, lonlat.lat); 
        }   
  
        this.map.zoomToExtent(bbox); 
    },

    /**
     * Method: recenterOnGeometry
     * Recenters on given geometry
     *
     * Parameters:
     * geometry - {<OpenLayers.Geometry>}
     */
    recenterOnGeometry: function(geometry) {
        if (geometry.CLASS_NAME == "OpenLayers.Geometry.Point") {
            this.recenterOnCoords(geometry.x, geometry.y);
        } else {
            this.recenterOnBbox(geometry.getBounds());
        }
    },
    
    /**
     * Method: showCenterMark
     * Materializes new center with a cross
     *
     * Parameters:
     * x - {Float} easting coordinate
     * y - {Float} northing coordinate
     */
    showCenterMark: function(x, y) {
        this.prepareVectorLayer();

        var features = [
            new OpenLayers.Feature.Vector(
                new OpenLayers.Geometry.Point(x, y),
                { type: this.symbol || 'cross' }
            )
        ];

        this.vectorLayer.addFeatures(features);
    },

    /**
     * Method: prepareVectorLayer
     * Adds a layer for displaying the center symbol. If it is already set, removes
     * existing features.
     */
    prepareVectorLayer: function() {
        if (this.vectorLayer) {
            this.vectorLayer.destroyFeatures();
        } else {
            var styles = new OpenLayers.StyleMap({
                "default": OpenLayers.Util.extend({
                    graphicName: "${type}", // retrieved from symbol type attribute
                    pointRadius: 10,
                    fillColor: "red",
                    fillOpacity: 1
                }, this.centerMarkStyles)
            });

            this.vectorLayer = new OpenLayers.Layer.Vector(
                "Center Symbol", {
                    styleMap: styles,
                    alwaysInRange: true
                }
            );

            this.map.addLayer(this.vectorLayer);
        }
    },

    /**
     * Method: showError
     * Displays an error message
     *
     * Parameters:
     * msg - {String} message
     * title - {String} box title
     */
    showError: function(msg, title) {
        title = title || OpenLayers.i18n('mf.error');
        Ext.Msg.alert(title, msg);
    },

    /**
     * Method: destroyLayer
     * Destroys the vector layer.
     */
    destroyLayer: function() {
        var layer = this.vectorLayer;
        if (layer) {
            layer.destroy();
            this.vectorLayer = null;
        }
    },
    
    /**
     * Method: destroyResources
     * Called when the feature editing panel is destroyed, takes care
     * of destroying all the resources that aren't destroyed by the
     * Ext.Panel destroy method.
     */
    destroyResources: function() {
        this.destroyLayer();
    }
    
});
