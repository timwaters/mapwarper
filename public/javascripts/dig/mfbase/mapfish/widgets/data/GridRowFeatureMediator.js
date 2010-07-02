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
 * @requires OpenLayers/Control/SelectFeature.js
 */

Ext.namespace('mapfish.widgets', 'mapfish.widgets.data');

/**
 * Class: mapfish.widgets.data.GridRowFeatureMediator
 * A mediator for selecting feature on grid row selection and
 * vice-vera.
 *
 * Usage example:
 * (start code)
 * var mediator = new mapfish.widgets.data.GridRowFeatureMediator({
 *     grid: grid,
 *     selectControl: selectFeatureControl
 * });
 * (end)
 */

/**
 * Constructor: mapfish.widgets.data.GridRowFeatureMediator
 * Create an instance of mapfish.widgets.data.GridRowFeatureMediator.
 *
 * Parameters:
 * config - {Object}
 *
 * Returns:
 * {<mapfish.widgets.data.GridRowFeatureMediator>}
 */
mapfish.widgets.data.GridRowFeatureMediator = function(config) {
    Ext.apply(this, config);
    if (!this.grid) {
        OpenLayers.Console.error(
            "no Ext.grid.GridPanel provided");
        return;
    }
    if (!this.selectControl ||
        this.selectControl.CLASS_NAME != "OpenLayers.Control.SelectFeature") {
        OpenLayers.Console.error(
            "no OpenLayers.Control.SelectFeature provided");
        return;
    }
    this.selectModel = this.grid.getSelectionModel();
    if (this.autoActivate) {
        this.activate();
    }
};

mapfish.widgets.data.GridRowFeatureMediator.prototype = {
    /**
     * APIProperty: autoActivate
     * {Boolean} The instance is activated at creation time, defaults
     *     to true.
     */
    autoActivate: true,

    /**
     * APIProperty: selectControl
     * {<OpenLayers.Control.SelectFeature>} The select feature control.
     */
    selectControl: null,

    /**
     * APIProperty: grid
     * {Ext.grid.GridPanel} The grid panel.
     */
    grid: null,

    /**
     * Property: selectModel
     * {Ext.grid.RowSelectionModel} The row selection model attached to
     *     the grid panel.
     */
    selectModel: null,

    /**
     * Property: active
     * {Boolean}
     */
    active: false,

    /**
     * APIMethod: activate
     * Activate the mediator.
     *
     * Returns:
     * {Boolean} - False if the mediator was already active, true
     * otherwise.
     */
    activate: function() {
        if (!this.active) {
            this.featureEventsOn();
            this.rowEventsOn();
            this.active = true;
            return true;
        }
        return false;
    },

    /**
     * APIMethod: deactivate
     * Deactivate the mediator.
     *
     * Returns:
     * {Boolean} - False if the mediator was already deactive, true
     * otherwise.
     */
    deactivate: function() {
        if (this.active) {
            this.featureEventsOff();
            this.rowEventsOff();
            this.active = false;
            return true;
        }
        return false;
    },

    /**
     * Method: featureSelected
     *
     * Parameters:
     * o - {Object} An object with a feature property referencing
     *     the selected feature.
     */
    featureSelected: function(o) {
        var r = this.grid.store.getById(o.feature.id);
        if (r) {
            this.rowEventsOff();
            this.selectModel.selectRecords([r]);
            this.rowEventsOn();

            // focus the row in the grid to ensure the row is visible
            this.grid.getView().focusRow(this.grid.store.indexOf(r));
        }
    },

    /**
     * Method: featureUnselected
     *
     * Parameters:
     * o - {Object} An object with a feature property referencing
     *     the selected feature.
     */
    featureUnselected: function(o) {
        var r = this.grid.store.getById(o.feature.id);
        if (r) {
            this.rowEventsOff();
            this.selectModel.deselectRow(this.grid.store.indexOf(r));
            this.rowEventsOn();
        }
    },

    /**
     * Method: rowSelected
     *
     * Parameters:
     * s - {Ext.grid.RowSelectModel} The row select model.
     * i - {Number} The row index.
     * r - {Ext.data.Record} The record.
     */
    rowSelected: function(s, i, r) {
        var layers = this.selectControl.layers || [this.selectControl.layer], f;
        for (var i = 0, len = layers.length; i < len; i++) {
            f = layers[i].getFeatureById(r.id);
            if (f) {
                this.featureEventsOff();
                this.selectControl.select(f);
                this.featureEventsOn();
                break;
            }
        }
    },

    /**
     * Method: rowDeselected
     *
     * Parameters:
     * s - {Ext.grid.RowSelectModel} The row select model.
     * i - {Number} The row index.
     * r - {Ext.data.Record} The record.
     */
    rowDeselected: function(s, i, r) {
        var layers = this.selectControl.layers || [this.selectControl.layer], f;
        for (var i = 0, len = layers.length; i < len; i++) {
            f = layers[i].getFeatureById(r.id);
            if (f) {
                this.featureEventsOff();
                this.selectControl.unselect(f);
                this.featureEventsOn();
            }
        }
    },

    /**
     * Method: rowEventsOff
     * Turn off the row events.
     */
    rowEventsOff: function() {
        this.selectModel.un("rowselect", this.rowSelected, this);
        this.selectModel.un("rowdeselect", this.rowDeselected, this);
    },

    /**
     * Method: rowEventsOn
     * Turn on the row events.
     */
    rowEventsOn: function() {
        this.selectModel.on("rowselect", this.rowSelected, this);
        this.selectModel.on("rowdeselect", this.rowDeselected, this);
    },

    /**
     * Method: featureEventsOff
     * Turn off the feature events.
     */
    featureEventsOff: function() {
        var layers = this.selectControl.layers || [this.selectControl.layer];
        for (var i = 0, len = layers.length; i < len; i++) {
            layers[i].events.un({
                featureselected: this.featureSelected,
                featureunselected: this.featureUnselected,
                scope: this
            });
        }
    },

    /**
     * Method: featureEventsOn
     * Turn on the feature events.
     */
    featureEventsOn: function() {
        var layers = this.selectControl.layers || [this.selectControl.layer];
        for (var i = 0, len = layers.length; i < len; i++) {
            layers[i].events.on({
                featureselected: this.featureSelected,
                featureunselected: this.featureUnselected,
                scope: this
            });
        }
    }
};
