/*
 * Copyright (C) 2009  Camptocamp
 *
 * This file is part of MapFish
 *
 * MapFish is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MapFish is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with MapFish.  If not, see <http://www.gnu.org/licenses/>.
 */

Ext.namespace('mapfish.widgets', 'mapfish.widgets.editing');

/**
 * Class: mapfish.widgets.editing.BaseProperty
 * Abstract base class for the properties object used in the layerConfig
 * property of the <mapfish.widgets.editing.FeatureEditingPanel> class.
 */
mapfish.widgets.editing.BaseProperty = function(config) {
    Ext.apply(this, config);
};

mapfish.widgets.editing.BaseProperty.prototype = {
    /**
     * Property: label
     * {String} - The label.
     */
    label: null,

    /**
     * Property: name
     * {String} - Name of the property. It is used as an identifier.
     */
    name: null,

    /**
     * Property: type
     * {String} - The type that is used for the building the record type of this
     *            property. See the documentation of Ext.data.Record.create for
     *            the available types.
     */
    type: null,

    /**
     * Property: showInGrid
     * {Boolean} - True to show this property in the columns of the grid of edited
     *             features.
     */
    showInGrid: false,

    /**
     * Property: defaultValue
     * {AnyType} - The default value to use when creating a new feature.
     */
    defaultValue: null,

    /**
     * Property: extFieldCfg
     * {Object} - The config object to pass to the constructor of the
     * underlying Ext field.
     */
    extFieldCfg: null,

    /**
     * Method: getRecordType
     *
     * Returns:
     * {Ext.data.Record} An Ext record type describing this property.
     */
    getRecordType: function() {
        return {
            name: this.name,
            type: this.type
        };
    },

    /**
     * Method: getExtField
     * Returns the Ext Field that will be shown in the attribute form panel.
     * This has to be overriden by specific subclasses.
     *
     * Returns:
     * {Ext.form.Field | Object} Ext Field or Object that is converted to a
     * Component.
     */
    getExtField: function() {
        OpenLayers.Console.error("Not implemented");
    }
};

/**
 * Class: mapfish.widgets.editing.SimpleProperty
 * Extends <mapfish.widgets.editing.BaseProperty> to show string or numeric
 * properties with an <Ext.form.TextField>. You shouldn't use this class
 * directly, but use one of the child.
 */
mapfish.widgets.editing.SimpleProperty = function(config) {
    mapfish.widgets.editing.SimpleProperty.superclass.constructor.call(this, config);
};

Ext.extend(mapfish.widgets.editing.SimpleProperty, mapfish.widgets.editing.BaseProperty, {
    /**
     * Method: getExtField
     * Return an object with a "textfield" xtype property.
     *
     * Returns:
     * {Object}
     */
    getExtField: function() {
        return OpenLayers.Util.applyDefaults({
            xtype: 'textfield',
            fieldLabel: this.label || this.name,
            name: this.name
        }, this.extFieldCfg);
    }
});

/**
 * Class: mapfish.widgets.editing.StringProperty
 * Extension of <mapfish.widgets.editing.BaseProperty> for string properties.
 */
mapfish.widgets.editing.StringProperty = function(config) {
    this.type = 'string';
    this.defaultValue = '';
    mapfish.widgets.editing.StringProperty.superclass.constructor.call(this, config);
};
Ext.extend(mapfish.widgets.editing.StringProperty, mapfish.widgets.editing.SimpleProperty);

/**
 * Class: mapfish.widgets.editing.IntegerProperty
 * Extension of <mapfish.widgets.editing.BaseProperty> for integer properties.
 */
mapfish.widgets.editing.IntegerProperty = function(config) {
    this.type = 'int';
    this.defaultValue = 0;
    mapfish.widgets.editing.IntegerProperty.superclass.constructor.call(this, config);
};
Ext.extend(mapfish.widgets.editing.IntegerProperty, mapfish.widgets.editing.SimpleProperty, {
    /**
     * Method: getExtField
     * Return an object with a "numberfield" xtype property.
     *
     * Returns:
     * {Object}
     */
    getExtField: function() {
        return OpenLayers.Util.applyDefaults({
            xtype: 'numberfield',
            allowDecimals: false,
            fieldLabel: this.label || this.name,
            name: this.name
        }, this.extFieldCfg);
    }
});

/**
 * Class: FloatProperty
 * Extension of <mapfish.widgets.editing.BaseProperty> for float properties.
 */
mapfish.widgets.editing.FloatProperty = function(config) {
    this.type = 'float';
    this.defaultValue = 0;
    mapfish.widgets.editing.FloatProperty.superclass.constructor.call(this, config);
};
Ext.extend(mapfish.widgets.editing.FloatProperty, mapfish.widgets.editing.SimpleProperty, {
    /**
     * Method: getExtField
     * Return an object with a "numberfield" xtype property.
     *
     * Returns:
     * {Object}
     */
    getExtField: function() {
        return OpenLayers.Util.applyDefaults({
            xtype: 'numberfield',
            fieldLabel: this.label || this.name,
            name: this.name
        }, this.extFieldCfg);
    }
});

/**
 * Class: BooleanProperty
 */
mapfish.widgets.editing.BooleanProperty = function(config) {
    this.type = 'boolean';
    this.defaultValue = false;
    mapfish.widgets.editing.FloatProperty.superclass.constructor.call(this, config);
};
Ext.extend(mapfish.widgets.editing.BooleanProperty, mapfish.widgets.editing.BaseProperty, {
    /**
     * Method: getExtField
     * Returns an Ext checkbox.
     *
     * Returns:
     * {Ext.form.Checkbox} The Ext checkbox.
     */
    getExtField: function() {
        return new Ext.form.Checkbox(OpenLayers.Util.applyDefaults({
            name: this.name,
            fieldLabel: this.label || this.name
        }, this.extFieldCfg));
    }
});

//{"parentType": "Residential", "id": "Apartments", "label": "Apartments"},



/**
 * Class: mapfish.widgets.editing.ComboStringProperty
 * A property that is shown as a combobox. The combobox values are retrieved
 * using Ajax lazyily. The url should be returned as JSON in the following format:

   {
     root: [
       {id: 'mylabel_1', label: 'My label 1'},
       {id: 'mylabel_2', label: 'My label 2'},
       {id: 'mylabel_3', label: 'My label 3'}
     ]
   }

 * This property will return the string identifier as a value (string), and
 * will show the label in the combobox.
 */
mapfish.widgets.editing.ComboStringProperty = function(config) {
    this.type = 'string';
    mapfish.widgets.editing.ComboStringProperty.superclass.constructor.call(this, config);
};

/**
 * For linked combo boxes
 * add in linked: 'this-id' to a parent box  and assign extFieldCfg: {id: 'this-id'} to the sub combo box
*/
Ext.extend(mapfish.widgets.editing.ComboStringProperty, mapfish.widgets.editing.BaseProperty, {
    /**
     * APIProperty: url
     * {String} - URL used for fetching the JSON data to fill the combobox. See
     *            the comment on the class for what format is expected.
     */
    url: null,

    /**
     * Method: getExtField
     * Return an Ext combo box whose content is retrieved through an
     * HTTP proxy configured with the "url" property.
     *
     * Returns:
     * {Ext.form.ComboBox} The Ext combo box.
     */
    getExtField: function() {
        var store = new Ext.data.Store({
            proxy: new Ext.data.HttpProxy({
                url: this.url,
                method: 'GET',
                disableCaching: false
            }),
            reader: new Ext.data.JsonReader({
                root: 'root'
              }, [
                {name: 'id', type: 'string'}, 'label', 'parentType'
            ])
        });
        var cfg = OpenLayers.Util.applyDefaults({
            fieldLabel: this.label || this.name,
            typeAhead: true,
            triggerAction: 'all',
            editable: false,
            displayField: 'label',
            valueField: 'id',
            name: this.name,
            linked: this.linked,
            linkedParent: this.linkedParent,
            store: store,
            // Load the store after the combobox is rendered. This way the
            // combobox shows the correct label when the record is loaded on
            // the form.
            listeners: {
                render: {
                    fn: function(combo) {
                        var params = {};
                        params[this.queryParam] = '';
                        this.store.load({
                            params: params
                        });
                        }
                },
                 beforeQuery: {
                    fn: function(query){
                        if (query.combo.linkedParent){
                          var parCombo = Ext.getCmp(query.combo.linkedParent);
                          var parComboVal = parCombo.getValue();
                          if (parComboVal == null) {
                            parComboVal = "";
                          }
                          query.query = parComboVal;
                          query.combo.allQuery = parComboVal;
                        } 
                        
                        }           
                              },
                 select: {
                    fn: function(combo, value) { 
                          if (combo.linked){
                            var subCombo = Ext.getCmp(combo.linked);
                             subCombo.setValue('');
                          }
                   }
                } 
                        
            }
        }, this.extFieldCfg);
        return new Ext.form.ComboBox(cfg);
    }
});



/**
 * Class: mapfish.widgets.editing.ComboProperty
 * A property that is shown as a combobox. The combobox values are retrieved
 * using Ajax lazyily. The url should be returned as JSON in the following format:

   {
     root: [
       {id: 1, label: 'My label 1'},
       {id: 2, label: 'My label 2'},
       {id: 3, label: 'My label 3'}
     ]
   }

 * This property will return the numerical identifier as a value (integer), and
 * will show the label in the combobox.
 */
mapfish.widgets.editing.ComboProperty = function(config) {
    this.type = 'int';
    mapfish.widgets.editing.ComboProperty.superclass.constructor.call(this, config);
};

Ext.extend(mapfish.widgets.editing.ComboProperty, mapfish.widgets.editing.BaseProperty, {
    /**
     * APIProperty: url
     * {String} - URL used for fetching the JSON data to fill the combobox. See
     *            the comment on the class for what format is expected.
     */
    url: null,

    /**
     * Method: getExtField
     * Return an Ext combo box whose content is retrieved through an
     * HTTP proxy configured with the "url" property.
     *
     * Returns:
     * {Ext.form.ComboBox} The Ext combo box.
     */
    getExtField: function() {
        var store = new Ext.data.Store({
            proxy: new Ext.data.HttpProxy({
                url: this.url,
                method: 'GET',
                disableCaching: false
            }),
            reader: new Ext.data.JsonReader({
                root: 'root'
            }, [
                {name: 'id', type: 'int'}, 'label'
            ])
        });
        var cfg = OpenLayers.Util.applyDefaults({
            fieldLabel: this.label || this.name,
            typeAhead: true,
            triggerAction: 'all',
            editable: false,
            displayField: 'label',
            valueField: 'id',
            name: this.name,
            store: store,
            // Load the store after the combobox is rendered. This way the
            // combobox shows the correct label when the record is loaded on
            // the form.
            listeners: {
                render: {
                    fn: function(combo) {
                        var params = {};
                        params[this.queryParam] = '';
                        this.store.load({
                            params: params
                        });
                    }
                }
            }
        }, this.extFieldCfg);
        return new Ext.form.ComboBox(cfg);
    }
});

/**
 * Class: mapfish.widgets.editing.DateProperty
 * A property that is shown as a date picker.
 *
 * This property will return a date string.
 */
mapfish.widgets.editing.DateProperty = function(config) {
    this.type = 'string';
    mapfish.widgets.editing.DateProperty.superclass.constructor.call(this, config);
};

Ext.extend(mapfish.widgets.editing.DateProperty, mapfish.widgets.editing.BaseProperty, {
    /**
     * Method: getExtField
     * Return an Ext date field.
     *
     * Returns:
     * {Ext.form.DateField} The Ext data field.
     */
    getExtField: function() {
        return new Ext.form.DateField(OpenLayers.Util.applyDefaults({
            fieldLabel: this.label || this.name,
            name: this.name
        }, this.extFieldCfg));
    }
});
