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
 * @requires widgets/print/BaseWidget.js
 */

Ext.namespace('mapfish.widgets');
Ext.namespace('mapfish.widgets.print');

/**
 * Class: mapfish.widgets.print.SimpleForm
 * Automatically takes the layers from the given {<OpenLayers.Map>} instance.
 *
 * If you put this panel directly inside an {Ext.TabPanel} or an accordion, it
 * will activate/desactivate automaticaly. But if you have more complex
 * layouts like windows or print panel in a panel in an {Ext.TabPanel}, it's
 * your responsability to call enable() and disable().
 *
 * Inherits from:
 * - {<mapfish.widgets.print.BaseWidget>}
 */

/**
 * Constructor: mapfish.widgets.print.SimpleForm
 *
 * Parameters:
 * config - {Object} Config object
 */

mapfish.widgets.print.SimpleForm = Ext.extend(mapfish.widgets.print.BaseWidget, {
    /**
     * APIProperty: formConfig
     * {Object} The configuration options passed to the form.
     *
     * Can contain additionnal items for custom fields. Their values will be
     * passed to the print service
     */
    formConfig: null,

    /**
     * APIProperty: formConfig
     * {Boolean} If true (default), display a reset position button
     */
    wantResetButton: true,

    /**
     * Property: scale
     * {Ext.form.ComboBox} The scale combobox.
     */
    scale: null,

    /**
     * Property: rectangle
     * {<OpenLayers.Feature.Vector>} The rectangle representing the extent.
     */
    rectangle: null,

    /**
     * Property: rotation
     * {Ext.form.TextField} The text field for editing the rotation.
     */
    rotation: null,

    /**
     * APIProperty: infoPanel
     * {Ext.Panel} An optional panel displayed after form fields.
     */
    infoPanel: null,

    /**
     * Method: fillComponent
     * Called by initComponent to create the component's sub-elements.
     */
    fillComponent: function() {
        var formConfig = OpenLayers.Util.extend({
            //by default, we don't want borders for the inner form
            border: false,
            bodyBorder: false
        }, this.formConfig);
        var formPanel = this.formPanel = new Ext.form.FormPanel(formConfig);

        var layout = this.createLayoutCombo("/layout");
        if (this.config.layouts.length > 1) {
            layout.on('select', this.updateRectangle, this);
        }
        formPanel.add(layout);

        formPanel.add(this.createDpiCombo("/dpi"));

        this.scale = formPanel.add(this.createScaleCombo());
        this.scale.on('select', this.updateRectangle, this);

        this.rotation = this.createRotationTextField();
        if (this.rotation != null) {
            this.rotation.setDisabled(!this.config.layouts[0].rotation);
            formPanel.add(this.rotation);
            this.rotation.on('change', function() {
                if (!this.rotation.isValid(true)) {
                    this.rotation.setValue(0);
                }
                this.updateRectangle();
            }, this);
        }

        if (this.infoPanel != null) {
            formPanel.add(this.infoPanel);
        }

        if (this.wantResetButton) {
            formPanel.addButton({
                text: OpenLayers.Lang.translate('mf.print.resetPos'),
                scope: this,
                handler: function() {
                    this.setCurScale(this.fitScale(this.getCurLayout()));
                    if (this.rotation) {
                        this.setCurRotation(0);
                    }
                    this.createTheRectangle();
                }
            });
        }

        formPanel.addButton({
            text: OpenLayers.Lang.translate('mf.print.print'),
            scope: this,
            handler: this.print
        });

        this.add(formPanel);
    },

    /**
     * Method: updateRectangle
     *
     * Called when the layout or the scale has been changed
     */
    updateRectangle: function() {
        this.layer.removeFeatures(this.rectangle);
        var center = this.rectangle.geometry.getBounds().getCenterLonLat();
        var layout = this.getCurLayout();
        this.rectangle = this.createRectangle(center,
                this.getCurScale(), layout,
                this.rotation && layout.rotation ? this.rotation.getValue() : 0);
        if (this.rotation) {
            //some layouts may have rotation disabled
            this.rotation.setDisabled(!layout.rotation);
            if (!layout.rotation) {
                this.rotation.setValue(0);
            }
        }
        if (layout.rotation) {
            this.createRotateHandle(this.rectangle);
        } else {
            this.removeRotateHandle();
        }
    },

    /**
     * Method: createTheRectangle
     *
     * Create the extent rectangle directly using the form's values
     */
    createTheRectangle: function() {
        if (this.rectangle) this.layer.removeFeatures(this.rectangle);
        var layout = this.getCurLayout();
        this.rectangle = this.createRectangle(this.map.getCenter(),
                this.getCurScale(), this.getCurLayout(),
                this.rotation && layout.rotation ? this.rotation.getValue() : 0);
        if (layout.rotation) {
            this.createRotateHandle(this.rectangle);
        }
    },

    /**
     * Method: afterLayerCreated
     * Called just after the layer has been created
     */
    afterLayerCreated: function() {
        this.setCurScale(this.fitScale(this.getCurLayout()));
        this.createTheRectangle();
    },

    /**
     * Method: getCurLayout
     *
     * Returns:
     * {Object} - The current layout config object
     */
    getCurLayout: function() {
        var values = this.formPanel.getForm().getValues();
        var layoutName = values['/layout'];
        return this.getLayoutForName(layoutName);
    },

    /**
     * Method: getCurScale
     *
     * Returns:
     * {Integer} - The scale currently selected
     */
    getCurScale: function() {
        var values = this.formPanel.getForm().getValues();
        return values['scale'];
    },

    /**
     * Method: setCurScale
     *
     * Parameters:
     * value - {Integer} the target scale
     */
    setCurScale: function(value) {
        this.scale.setValue(value);
    },

    /**
     * Method: getCurDpi
     *
     * Returns:
     * {Integer} - the user selected DPI.
     */
    getCurDpi: function() {
        var values = this.formPanel.getForm().getValues();
        return values["dpi"];
    },

    /**
     * Method: setCurRotation
     *
     * Called when the rotation of the current page has been changed.
     *
     * Parameters:
     * rotation - {Float}
     */
    setCurRotation: function(rotation) {
        this.rotation.setValue(rotation);
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
            center: this.getCenterRectangle(this.rectangle)
        };
        var params = printCommand.spec;
        params.pages.push(singlePage);

        this.formPanel.getForm().items.each(function(cur) {
            var name = cur.getName();
            if (OpenLayers.String.startsWith(name, "/")) {
                params[name.substr(1)] = cur.getValue();
            } else {
                singlePage[name] = cur.getValue();
            }
        }, this);
    }
});

Ext.reg('print-simple', mapfish.widgets.print.SimpleForm);
