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
 * @requires widgets/recenter/Base.js
 */

Ext.namespace('mapfish.widgets', 'mapfish.widgets.recenter');

/**
 * Class: mapfish.widgets.recenter.Coords
 * Recenters  (and zooms if asked) on user-provided coordinates.
 *
 * Typical usage:
 * (start code)
 * var coordsrecenter = new mapfish.widgets.recenter.Coords({
 *    el: 'myDiv',
 *    map: map,
 *    scales: config.scales, // list of available scales.
 *                           // ie. [100000, 50000, 25000, 10000]
 *                           // If not provided, no scales combo is displayed
 *    showCenter: true,      // boolean, indicates if a symbol must be shown
 *                           // at the new center
 *    defaultZoom: 4         // zoom level used if no zoom level is provided by
 *                           // the user. If no zoom level value is available,
 *                           // zoom level remains unchanged.
 * });
 * (end)
 *
 * Inherits from:
 * - {<mapfish.widgets.recenter.Base>}
 */

/**
 * Constructor: mapfish.widgets.recenter.Coords
 *
 * Parameters:
 * config - {Object} The config object used to set the recenter on coordinates
 *      properties, see beloaw for an example of usage.
 * Returns:
 * {<mapfish.widgets.recenter.Coords>}
 */
mapfish.widgets.recenter.Coords = function(config) {
    Ext.apply(this, config);
    mapfish.widgets.recenter.Coords.superclass.constructor.call(this);
};

Ext.extend(mapfish.widgets.recenter.Coords, mapfish.widgets.recenter.Base, {

    /**
     * Method: addItems
     *
     * Adds the items.
     *
     * Usefull to defer add items when container layout is accordion,
     *      Called either by render or expand.
     *      The latter is to prevent Ext failing when computing form items
     *      sizes in not displayed elements (accordion layouts).
     *
     */
    addItems: function() {
        // first remove any existing item
        this.removeAll();

        this.add({
            xtype: 'numberfield',
            fieldLabel: OpenLayers.i18n('mf.recenter.x'),
            name: 'coordx'
        });

        this.add({
            xtype: 'numberfield',
            fieldLabel: OpenLayers.i18n('mf.recenter.y'),
            name: 'coordy'
        });

        if (this.scales) {
            this.addScaleCombo();
        }

        this.addRecenterButton();
    },

    /**
     * Method: recenter
     * Recenters map using user-provided coordinates and scale.
     */
    recenter: function() {
        var values = this.getForm().getValues();
        var x = values.coordx;
        var y = values.coordy;
        
        if (this.checkCoords(x, y)) {
            
            var zoom;

            if (this.scales && values.scaleValue) {
                // use user-provided scale
                resolution = OpenLayers.Util.getResolutionFromScale(values.scaleValue,
                        this.map.units);
                zoom = this.map.getZoomForResolution(resolution);
            }

            this.recenterOnCoords(x, y, zoom);
        }
    },

    /** 
     * Method: checkCoords
     * Checks that submitted coordinates are well-formatted and within the map bounds.
     *
     * Parameters:
     * x {Float} - easting coordinate
     * y {Float} - northing coordinate
     *
     * Returns: 
     * {Boolean}
     */
    checkCoords: function(x, y) {
    
        if (!x || !y) {
            this.showError(OpenLayers.i18n('mf.recenter.missingCoords'));
            return false;
        }

        var maxExtent = this.map.maxExtent;
    
        if (x < maxExtent.left || x > maxExtent.right ||
            y < maxExtent.bottom || y > maxExtent.top) {
            this.showError(OpenLayers.i18n('mf.recenter.outOfRangeCoords', {
                'myX': x,
                'myY': y,
                'coordX': OpenLayers.i18n('mf.recenter.x'),
                'coordY': OpenLayers.i18n('mf.recenter.y'),
                'minCoordX': maxExtent.left,
                'maxCoordX': maxExtent.right,
                'minCoordY': maxExtent.bottom,
                'maxCoordY': maxExtent.top
            }));
            return false;
        }
    
        return true;
    }
});

Ext.reg('coordsrecenter', mapfish.widgets.recenter.Coords);
