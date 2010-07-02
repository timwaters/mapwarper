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
 * @requires core/GeoStat/ProportionalSymbol.js
 */

Ext.namespace('mapfish.widgets', 'mapfish.widgets.geostat');

/**
 * Class: mapfish.widgets.geostat.ProportionalSymbol
 * Use this class to create a widget allowing to display proportional
 * symbols on the map.
 *
 * Inherits from:
 * - {Ext.FormPanel}
 */
mapfish.widgets.geostat.ProportionalSymbol = Ext.extend(Ext.FormPanel, {

    /**
     * APIProperty: layer
     * {<OpenLayers.Layer.Vector>} The vector layer containing the features that
     *      are styled based on statistical values. If none is provided, one will
     *      be created.
     */
    layer: null,

    /**
     * APIProperty: format
     * {<OpenLayers.Format>} The OpenLayers format used to get features from
     *      the HTTP request response. GeoJSON is used if none is provided.
     */
    format: null,

    /**
     * APIProperty: url
     * {String} The URL to the web service. If none is provided, the features
     *      found in the provided vector layer will be used.
     */
    url: null,

    /**
     * APIProperty: featureSelection
     * {Boolean} A boolean value specifying whether feature selection must
     *      be put in place. If true a popup will be displayed when the
     *      mouse goes over a feature.
     */
    featureSelection: true,

    /**
     * APIProperty: nameAttribute
     * {String} The feature attribute that will be used as the popup title.
     *      Only applies if featureSelection is true.
     */
    nameAttribute: null,
    
    /**
     * APIProperty: indicator
     * {String} (read-only) The feature attribute currently chosen
     *     Useful if callbacks are registered on 'featureselected'
     *     and 'featureunselected' events
     */
    indicator: null,
    
    /**
     * APIProperty: indicatorText
     * {String} (read-only) The raw value of the currently chosen indicator
     *     (ie. human readable)
     *     Useful if callbacks are registered on 'featureselected'
     *     and 'featureunselected' events
     */
    indicatorText: null,

    /**
     * Property: coreComp
     * {<mapfish.GeoStat.ProportionalSymbol>} The core component object.
     */
    coreComp: null,

    /**
     * Property: classificationApplied
     * {Boolean} true if the classify was applied
     */
    classificationApplied: false,

    /**
     * Property: ready
     * {Boolean} true if the widget is ready to accept user commands.
     */
    ready: false,

    /**
     * Property: border
     *     Styling border
     */
    border: false,
    
    /**
     * APIProperty: loadMask
     *     An Ext.LoadMask config or true to mask the widget while loading (defaults to false).
     */
    loadMask : false,

    /**
     * Constructor: mapfish.widgets.geostat.ProportionalSymbol
     *
     * Parameters:
     * config - {Object} Config object.
     */

    /**
     * Method: initComponent
     *    Inits the component
     */
    initComponent : function() {
        this.items = [{
            xtype: 'combo',
            fieldLabel: 'Indicator',
            name: 'indicator',
            editable: false,
            valueField: 'value',
            displayField: 'text',
            mode: 'local',
            emptyText: 'select an indicator',
            triggerAction: 'all',
            store: new Ext.data.SimpleStore({
                fields: ['value', 'text'],
                data : this.indicators
            })
        },{
            xtype: 'numberfield',
            fieldLabel:'Min Size',
            name: 'minSize',
            width: 30,
            value: 2,
            maxValue: 20
        },{
            xtype: 'numberfield',
            fieldLabel:'Max Size',
            name: 'maxSize',
            width: 30,
            value: 20,
            maxValue: 50
        }];
        
        
        this.buttons = [{
            text: 'OK',
            handler: this.classify,
            scope: this
        }];
        mapfish.widgets.geostat.ProportionalSymbol.superclass.initComponent.apply(this);
    },

    /**
     * Method: requestSuccess
     *      Calls onReady callback function and mark the widget as ready.
     *      Called on Ajax request success.
     */
    requestSuccess: function(request) {
        this.ready = true;
        
        // if widget is rendered, hide the optional mask
        if (this.loadMask && this.rendered) {
            this.loadMask.hide();
        }
    },

    /**
     * Method: requestFailure
     *      Displays an error message on the console.
     *      Called on Ajax request failure.
     */
    requestFailure: function(request) {
        OpenLayers.Console.error('Ajax request failed');
    },
        
    /**
     * Method: classify
     *    Reads the features to get the different value for
     *    the field given for indicator
     *    Creates a new Distribution and related Classification
     *    Then creates an new ProportionalSymbols and applies classification
     */
    classify: function() {
        if (!this.ready) {
            if (exception) {
                Ext.MessageBox.alert('Error', 'Component init not complete');
            }
            return;
        }
        this.indicator = this.form.findField('indicator').getValue();
        this.indicatorText = this.form.findField('indicator').getRawValue();
        if (!this.indicator) {
            Ext.MessageBox.alert('Error', 'You must choose an indicator');
            return;
        }
        var minSize = this.form.findField('minSize').getValue();
        var maxSize = this.form.findField('maxSize').getValue();
        this.coreComp.updateOptions({
            'indicator': this.indicator,
            'minSize': minSize,
            'maxSize': maxSize
        });
        this.coreComp.applyClassification();
        this.classificationApplied = true;
    },

    /**
     * Method: onRender
     * Called by EXT when the component is rendered.
     */
    onRender: function(ct, position) {
        mapfish.widgets.geostat.Choropleth.superclass.onRender.apply(
                this, arguments);
        
        if(this.loadMask){
            this.loadMask = new Ext.LoadMask(this.bwrap,
                    this.loadMask);
            this.loadMask.show();
        }
        
        this.coreComp = new mapfish.GeoStat.ProportionalSymbol(this.map, {
            'layer': this.layer,
            'format': this.format,
            'url': this.url,
            'requestSuccess': this.requestSuccess.createDelegate(this),
            'requestFailure': this.requestFailure.createDelegate(this),
            'featureSelection': this.featureSelection,
            'nameAttribute': this.nameAttribute
        });
    }
});
Ext.reg('proportionalsymbol', mapfish.widgets.geostat.ProportionalSymbol);
