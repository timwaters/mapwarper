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

Ext.namespace('mapfish.widgets');

/**
 * Class: mapfish.widgets.MapComponent
 *
 * A map container in order to be able to insert a map into a complex layout
 * Its main interest is to update the map size when the container is resized
 *
 * Simple example usage:
 * > var mapcomponent = new mapfish.widgets.MapComponent({map: map});
 *
 * Inherits from:
 * - {Ext.Panel}
 */

/*
 * Constructor: mapfish.widgets.MapComponent
 * Create a new MapComponent.
 *
 * Parameters:
 * config - {Object} The config object
 */
mapfish.widgets.MapComponent = function(config) {
    Ext.apply(this, config);
    this.contentEl = this.map.div;

    // Set the map container height and width to avoid css 
    // bug in standard mode. 
    // See https://trac.mapfish.org/trac/mapfish/ticket/85
    var content = Ext.get(this.contentEl);
    content.setStyle('width', '100%');
    content.setStyle('height', '100%');
    
    mapfish.widgets.MapComponent.superclass.constructor.call(this);
};

Ext.extend(mapfish.widgets.MapComponent, Ext.Panel, {
    /**
     * APIProperty: map
     * {<OpenLayers.Map>} A reference to the OpenLayers map object.
     */
    map: null,

    initComponent: function() {
        mapfish.widgets.MapComponent.superclass.initComponent.apply(this, arguments);
        this.on("bodyresize", this.map.updateSize, this.map);
    }
});
Ext.reg('mapcomponent', mapfish.widgets.MapComponent);
