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
 * @requires widgets/data/FeatureReader.js
 */

Ext.namespace('mapfish.widgets', 'mapfish.widgets.data');

/**
 * Class: mapfish.widgets.data.FeatureStore
 * Helper class to ease creating stores of features. An instance of this
 * class is pre-configured with a <mapfish.widgets.data.FeatureReader>.
 *
 * Typical usage in a store:
 * (start code)
 *         var store = new Ext.data.FeatureStore({
 *             fields: [
 *                 {name: 'name', type: 'string'},
 *                 {name: 'elevation', type: 'float'}
 *             ]
 *         });
 *         store.loadData(features);
 * (end)
 *
 * Inherits from:
 *  - {Ext.data.Store}
 */

/**
 * Constructor: mapfish.widgets.data.FeatureStore
 * Create a feature store, the options passed in the config object are
 * similar to those passed to an Ext.data.Store constructor; in addition
 * the config object must include a "fields" property referencing an Array
 * of field definition objects as passed to Ext.data.Record.create, or a
 * Record constructor created using Ext.data.Record.create.
 *
 * Parameters:
 * config {Object} The config object.
 *
 * Returns:
 * {<mapfish.widgets.data.FeatureStore>} The feature store.
 */
mapfish.widgets.data.FeatureStore = function(config) {
    mapfish.widgets.data.FeatureStore.superclass.constructor.call(this, {
        reader:  new mapfish.widgets.data.FeatureReader(
            config, config.fields
        )
    });
};
Ext.extend(mapfish.widgets.data.FeatureStore, Ext.data.Store, {
    /**
     * APIProperty: fields
     * {Object} An Array of field definition objects as passed to
     * Ext.data.Record.create, or a Record constructor created using
     * Ext.data.Record.create.
     */
    fields: null
});
