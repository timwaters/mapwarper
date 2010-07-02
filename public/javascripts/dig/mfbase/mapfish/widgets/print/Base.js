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
 * @requires core/PrintProtocol.js
 * @requires core/Util.js
 */

Ext.namespace('mapfish.widgets');
Ext.namespace('mapfish.widgets.print');

/**
 * Class: mapfish.widgets.print.Base
 * Base class for the Ext components used to communicate with the print module,
 * automatically take the layers from the given {<OpenLayers.Map>} instance.
 */

mapfish.widgets.print.Base = {
    /**
     * APIProperty: map
     * {<OpenLayers.Map>} The OpenLayers Map object.
     */
    map: null,

    /**
     * APIProperty: overrides
     * {Object} the map that specify the print module overrides for each layers.
     *    They can be used of changing the OL layer's bahaviors for the print
     *   module. See the documentation in {<mapfish.PrintProtocol>}.
     */
    overrides: null,

    /**
     * APIProperty: configUrl
     * {String} The URL to access .../config.json. Either this property or
     *          config must be set.
     */
    configUrl: null,

    /**
     * APIProperty: config
     * {Object} The response from .../config.json. Either this property or
     *          configUrl must be set.
     */
    config: null,

    /**
     * APIProperty: layerTree
     * {<mapfish.widgets.LayerTree>} An optional layer tree. Needed only if you
     *                              want to display legends.
     */
    layerTree: null,

    /**
     * APIProperty: grids
     * {Object} An optional dictionary of {Ext.grid.GridPanel}. Needed only
     *          if you want to display search results. Can be function
     *          (returning the dictionary) that will be called each time the
     *          information is needed.
     */
    grids: null,

    /**
     * APIProperty: serviceParams
     * {Object} Additional params to send in the print service Ajax calls. Can
     *          be used to set the "locale" parameter.
     */
    serviceParams: null,

    /**
     * Property: mask
     * {Ext.LoadingMask} The mask used when loading the configuration or
     *                   when generating the PDF
     */
    mask: null,

    /**
     * APIProperty: printing
     * {Boolean} True when a PDF is being generated. Read-only.
     */
    printing: false,

    /**
     * Method: initPrint
     * loads the configuration
     *
     * Returns:
     * {Boolean} true if the configuration needs loading.
     */
    initPrint: function() {
        if (this.overrides == null) {
            this.overrides = {};
        }

        if (this.config == null) {
            mapfish.PrintProtocol.getConfiguration(this.configUrl,
                    this.configReceived, this.configFailed, this, this.serviceParams);
            return true;
        } else {
            this.fillComponent();
            return false;
        }
    },

    /**
     * Method: configReceived
     * Called once the config has been received
     *
     * Parameters:
     * config - {Object} the config
     */
    configReceived: function(config) {
        this.config = config;
        if (this.mask) {
            this.mask.hide();
        }
    },

    /**
     * Method: configFailed
     * Called if we were unable to get the config.
     */
    configFailed: function() {
        if (this.mask) {
            this.mask.hide();
        }
    },

    /**
     * Method: print
     *
     * Do the actual printing.
     */
    print: function() {
        if (this.mask) {
            this.mask.msg = OpenLayers.Lang.translate('mf.print.generatingPDF');
            this.mask.show();
        }

        var printCommand = new mapfish.PrintProtocol(this.map, this.config,
                this.overrides, this.getCurDpi(), this.serviceParams);
        if (this.layerTree) {
            this.addLegends(printCommand.spec);
        }
        if (this.grids) {
            this.addGrids(printCommand.spec);
        }
        this.fillSpec(printCommand);

        this.printing = true;
        printCommand.createPDF(
                function() { //success
                    if (this.mask) this.mask.hide();
                    this.printing = false;
                },
                function(request) { //popup
                    // don't use an Ext button... for some reason the IE "automatic
                    // download" stuff kick in with those.

                    var onClick = 'Ext.getCmp(\'printPopup\').destroy();';
                    if (Ext.isOpera) {
                        // Opera doesn't respect the "Content-disposition:
                        // attachment", so we have to open a new tab 
                        onClick += 'window.open(\'' + request.getURL + '\', \'_blank\');';
                    } else {
                        onClick += 'window.location=\'' + request.getURL + '\';';
                    }
                    var content = OpenLayers.Lang.translate('mf.print.pdfReady') + '<br /><br />' +
                                  '<table onclick="' + onClick + '" border="0" cellpadding="0" cellspacing="0" class="x-btn-wrap" align="center">' +
                                  '<tbody><tr><td class="x-btn-left"><i>&#160;</i></td>' +
                                  '<td class="x-btn-center"><em unselectable="on" class="x-btn x-btn-text">' + Ext.MessageBox.buttonText.ok + '</em></td>' +
                                  '<td class="x-btn-right"><i>&#160;</i></td></tr>' +
                                  '</tbody></table>';
                    var popup = new Ext.Window({
                        bodyStyle: 'padding: 7px;',
                        width: 200,
                        id: "printPopup",
                        autoHeight: true,
                        constrain: true,
                        closable: false,
                        title: OpenLayers.Lang.translate('mf.information'),
                        html: content,
                        listeners: {
                            destroy: function() {
                                if (this.mask) this.mask.hide();
                                this.printing = false;
                            },
                            scope: this
                        }
                    });
                    popup.show();
                },
                function(request) { //failure
                    Ext.Msg.alert(OpenLayers.Lang.translate('mf.error'),
                            OpenLayers.Lang.translate('mf.print.unableToPrint'));
                    if (this.mask) this.mask.hide();
                    this.printing = false;
                },
                this);
    },

    /**
     * Method: addGrids
     *
     * Add the grids' data to the given spec.
     *
     * Parameters:
     * spec - {Object} The print spec to fill.
     */
    addGrids: function(spec) {
        var grids = this.grids;
        if (grids && typeof grids == "function") {
            grids = grids();
        }
        if (grids) {
            for (var name in grids) {
                var grid = grids[name];
                if (!grid) {
                    continue;
                }
                spec[name] = {};
                var specData = spec[name].data = [];
                var specCols = spec[name].columns = [];
                var columns = grid.getColumnModel();
                var store = grid.getStore();
                for (var j = 0; j < columns.getColumnCount(); ++j) {
                    if (!columns.isHidden(j)) {
                        specCols.push(columns.getDataIndex(j));
                    }
                }
                store.each(function(record) {
                    var hash = {};
                    for (var key in record.data) {
                        var val = record.data[key];
                        if (val != null) {
                            if (val.CLASS_NAME && val.CLASS_NAME == 'OpenLayers.Feature.Vector') {
                                val = new OpenLayers.Format.WKT().write(val);
                            }
                            hash[key] = val;
                        }
                    }
                    specData.push(hash);
                }, this);
            }
        }
    },

    /**
     * Method: addLegends
     *
     * Add the layerTree's legends to the given spec.
     *
     * Parameters:
     * spec - {Object} The print spec to fill.
     */
    addLegends: function(spec) {
        var legends = spec.legends = [];

        function addLayer(layerNode) {
            var layerInfo = {
                name: layerNode.attributes.printText || layerNode.attributes.text,
                icon: mapfish.Util.relativeToAbsoluteURL(layerNode.attributes.icon)
            };
            var classesInfo = layerInfo.classes = [];
            layerNode.eachChild(function(classNode) {
                classesInfo.push({
                    name: classNode.attributes.printText || classNode.attributes.text,
                    icon:  mapfish.Util.relativeToAbsoluteURL(classNode.attributes.icon)
                });
            }, this);
            legends.push(layerInfo);
        }

        function goDeep(root) {
            root.eachChild(function(node) {
                var attr = node.attributes;
                if (attr.checked && attr.layerNames && !attr.hidden && attr.printText!=='') {
                    addLayer(node);
                } else {
                    goDeep(node);
                }
            }, this);
        }
        goDeep(this.layerTree.getRootNode());

        if (legends.length == 0) {
            //don't display the legends block if there is none
            delete spec.legends;
        }
    },

    /**
     * APIMethod: fillSpec
     * Add the page definitions and set the other parameters. To be implemented
     * by child classes.
     * 
     * This method can be overriden to customise the spec sent to the printer.
     * Don't forget to call the parent implementation.
     *
     * Parameters:
     * printCommand - {<mapfish.PrintProtocol>} The print definition to fill.
     */
    fillSpec: null,

    /**
     * Method: getCurDpi
     *
     * Returns the user selected DPI. To be implemented by child classes.
     */
    getCurDpi: null
};
