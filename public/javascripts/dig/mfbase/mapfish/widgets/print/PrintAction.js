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

/*
 * @requires widgets/print/Base.js
 */

Ext.namespace('mapfish.widgets');
Ext.namespace('mapfish.widgets.print');

/**
 * Class: mapfish.widgets.print.PrintAction
 * An OpenLayers control that generates a PDF based on the Map's extent
 *
 * Inherits from:
 * - {Ext.Action}
 * - {<mapfish.widgets.print.Base>}
 */

/**
 * Constructor: mapfish.widgets.print.PrintAction
 *
 * Parameters:
 * config - {Object} Config object
 */

mapfish.widgets.print.PrintAction = function(config) {
    var actionParams = OpenLayers.Util.extend({
        iconCls: 'mf-print-action',
        text: OpenLayers.Lang.translate('mf.print.print'),
        tooltip: OpenLayers.Lang.translate('mf.print.print-tooltip'),
        handler: this.handler,
        scope: this
    }, config);
    mapfish.widgets.print.PrintAction.superclass.constructor.call(this, actionParams);
    OpenLayers.Util.extend(this, config);

    this.mask = new Ext.LoadMask(this.map.div, {
        msg: OpenLayers.Lang.translate('mf.print.loadingConfig')
    });
    this.initPrint();
};

Ext.extend(mapfish.widgets.print.PrintAction, Ext.Action, {
    /**
     * Method: handler
     *
     * Called when the action is executed (button pressed or menu entry selected).
     */
    handler: function() {
        if (!this.printing && this.config) {
            this.print();
        }
    },

    /**
     * APIMethod: fillSpec
     * Add the page definitions and set the other parameters.
     *
     * This method can be overriden to customise the spec sent to the printer.
     * Don't forget to call the parent implementation.
     *
     * Parameters:
     * printCommand - {<mapfish.PrintProtocol>} The print definition to fill.
     */
    fillSpec: function(printCommand) {
        var singlePage = {
            bbox: this.map.getExtent().toArray()
        };
        var params = printCommand.spec;
        params.pages.push(singlePage);
        params.layout = this.getCurLayout();
    },

    /**
     * APIMethod: getCurDpi
     *
     * Override this method if you want to use another logic.
     *
     * Returns:
     * the first DPI.
     */
    getCurDpi: function() {
        return this.config.dpis[0].value;
    },

    /**
     * APIMethod: getCurLayout
     *
     * Override this method if you want to use another logic.
     *
     * Returns:
     * the first Layout.
     */
    getCurLayout: function() {
        return this.config.layouts[0].name;
    }
});

OpenLayers.Util.applyDefaults(mapfish.widgets.print.PrintAction.prototype, mapfish.widgets.print.Base);

Ext.reg('print-action', mapfish.widgets.print.PrintAction);
