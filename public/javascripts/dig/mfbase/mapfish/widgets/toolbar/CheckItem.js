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
 * Class: mapfish.widgets.toolbar.CheckItem
 * A Check item is associated with an OpenLayers Handler through an OpenLayers Control.
 * This class also adds quicktips.
 *
 * Simple example usage:
 * (start code)
 * var checkItem = new mapfish.widgets.toolbar.CheckItem({
 *     text: 'My menu item',
 *     tooltip: 'My tooltip', 
 *     control: new OpenLayers.Control.Navigation(), 
 *     olHandler: 'wheelHandler'
 * });
 * (end)
 *
 * Inherits from:
 * - {Ext.menu.CheckItem}
 */

/**
 * Constructor: mapfish.widgets.toolbar.CheckItem
 * Create a new CheckItem
 *
 * Parameters:
 * config - {Object} Config object
 */

mapfish.widgets.toolbar.CheckItem = function(config) {
    Ext.apply(this, config);
    mapfish.widgets.toolbar.CheckItem.superclass.constructor.call(this);
};

Ext.extend(mapfish.widgets.toolbar.CheckItem, Ext.menu.CheckItem, {

    /**
     * Property: controlAdded
     * {Boolean}
     */
    controlAdded: false,
    
    /**
     * Property: olHandler
     * {String}
     */
    olHandler: null,

    // private
    initComponent: function() {
        mapfish.widgets.toolbar.CheckItem.superclass.initComponent.call(this);
        Ext.QuickTips.init();
        if (this.control) {
            this.scope = this;
            this.checkHandler = this.handleChecked;
        }
    },

    handleChecked: function(item, checked) {
      if (!this.controlAdded) {
          this.map.addControl(this.control);
          this.controlAdded = true;
      }
      if (checked) {
          if (!this.olHandler) {
              // show control, there is currently no real API method to do this
              if (this.control.div) {
                  this.control.div.style.display = 'block';
              }
          } else {
              // deactivate the other handlers
              this.control.deactivate();
              eval('this.control.'+this.olHandler+'.activate();');
          }
      } else {
          if (!this.olHandler) {
            // hide control, ideally also deregister the events but no API 
            // method currently
            if (this.control.div) {
                this.control.div.style.display = 'none';
            }
          } else {
              this.control.deactivate();
          }
      }
      this.saveState();
    },

    /**
     * Method: getState
     * Function that builds op the state of the checkitem and returns it
    */
    getState: function() {
        return {className: this.control.CLASS_NAME, 
                olHandler: this.olHandler, 
                active: this.checked};
    },

    /**
     * Method: applyState
     * Apply the state to the checkitem upon loading
     *
     * Parameters:
     * state - {<Object>}
    */
    applyState: function(state) {
        if (!state) {
            return false;
        }
        if (this.control.CLASS_NAME == state.className && this.olHandler == state.olHandler) {
            this.checked = state.active;
        } else if (this.control.CLASS_NAME == state.className) {
            this.checked = state.active;
        }
        this.handleChecked(null, this.checked);
    },

    // private
    onRender: function(container, position) {
        mapfish.widgets.toolbar.CheckItem.superclass.onRender.apply(this, arguments);
        if (this.tooltip) {
            this.el.dom.qtip = this.tooltip;
        }
    }
});
Ext.reg('checkitem', mapfish.widgets.toolbar.CheckItem);
