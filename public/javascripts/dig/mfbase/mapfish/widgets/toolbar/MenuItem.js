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

Ext.namespace('mapfish.widgets.toolbar');

/**
 * Class: mapfish.widgets.toolbar.MenuItem
 * A Menu item is associated with an OpenLayers Control of type BUTTON and will call trigger on it.
 * This class also add quicktips.
 *
 * Simple example usage:
 * (start code)
 * var menuItem = new mapfish.widgets.toolbar.MenuItem({
 *     text: 'My menu item',
 *     tooltip: 'My tooltip', 
 *     icon: 'lib/openlayers/theme/default/img/icon_roi_feature.png',
 *     control: new OpenLayers.Control.ROISelect({map: map})
 * });
 * (end)
 *
 * Inherits from:
 * - {Ext.menu.Item}
 */

/**
 * Constructor: mapfish.widgets.toolbar.MenuItem
 * Create a new MenuItem.
 *
 * Parameters:
 * config - {Object} Config object
 */

mapfish.widgets.toolbar.MenuItem = function(config) {
    Ext.apply(this, config);
    mapfish.widgets.toolbar.MenuItem.superclass.constructor.call(this);
};

Ext.extend(mapfish.widgets.toolbar.MenuItem, Ext.menu.Item, {

    // private
    initComponent: function() {
        mapfish.widgets.toolbar.MenuItem.superclass.initComponent.call(this);
        Ext.QuickTips.init();
        if (this.control) {
            this.scope = this;
            this.handler = function() { this.control.trigger(); };
        }
    },

    // private
    onRender : function(container, position) {
        mapfish.widgets.toolbar.MenuItem.superclass.onRender.apply(this, arguments);
        if (this.tooltip) {
            this.el.dom.qtip = this.tooltip;
        }
    }
});
Ext.reg('menuitem', mapfish.widgets.toolbar.MenuItem);
