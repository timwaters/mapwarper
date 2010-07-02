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
 * Function: mapfish.widgets.createScaleComboBox
 * 
 * Parameters:
 * config - {Object} The config object, with at least a scales property
 * comboConfig - {Object} The combo config object (ie. Ext.form.ComboBox standard config comboConfig).
 *      Be aware that the store config property is overwritten.
 *
 * Returns:
 * {Ext.form.ComboBox} A combobox with formated scales
 */
mapfish.widgets.createScaleComboBox = function(config, comboConfig) {
    
    if (!config.scales) {
        OpenLayers.Console.error(
            "scales is missing in the config");
    }

    /**
     * Method: formatScale
     * Formats the scale to be used as displayField in the combo
     *      to render something like 1:5'000.
     *
     *      In the future, we could imagine a mapfish.widgets.Format.scale method
     *      with args like for Ext.Util.Format.date.
     *
     * Parameters:
     * value - {Float}
     *
     * Returns:
     * {String} The formated scale.
     */
    var formatScale = function(value) {
        value = String(Math.round(value));
        var rgx = /(\d+)(\d{3})/;

        while (rgx.test(value)) {
            value = value.replace(rgx, '$1' + "'" + '$2');
        }

        return '1:' + value;
    };

    var store = [];
    for (var i = 0; i < config.scales.length; i++) {
        store.push([
            config.scales[i],
            formatScale(config.scales[i])
        ]);
    }

    return new Ext.form.ComboBox(Ext.apply(comboConfig, {store: store}));
};