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

Ext.namespace('mapfish.widgets', 'mapfish.widgets.data');

/**
 * Class: mapfish.widgets.data.FeatureReader
 *      FeatureReader is a specific Ext.data.DataReader. When records are
 *      added to the store using this reader, specific fields like
 *      feature, state and fid are available.
 *
 * Typical usage in a store:
 * (start code)
 *         var store = new Ext.data.Store({
 *             reader: new mapfish.widgets.data.FeatureReader({}, [
 *                 {name: 'name', type: 'string'},
 *                 {name: 'elevation', type: 'float'}
 *             ])
 *         });
 * (end)
 *
 * Inherits from:
 *  - {Ext.data.DataReader}
 */

/**
 * Constructor: mapfish.widgets.data.FeatureReader
 *      Create a feature reader. The arguments passed are similar to those
 *      passed to {Ext.data.DataReader} constructor.
 */
mapfish.widgets.data.FeatureReader = function(meta, recordType){
    meta = meta || {};
    mapfish.widgets.data.FeatureReader.superclass.constructor.call(
        this, meta, recordType || meta.fields
    );
};

Ext.extend(mapfish.widgets.data.FeatureReader, Ext.data.DataReader, {

    /**
     * APIProperty: totalRecords
     * {Integer}
     */
    totalRecords: null,

    /**
     * APIMethod: read
     * This method is only used by a DataProxy which has retrieved data.
     *
     * Parameters:
     * response - {<OpenLayers.Protocol.Response>}
     *
     * Returns:
     * {Object} An object with two properties. The value of the property "records"
     *      is the array of records corresponding to the features. The value of the
     *      property "totalRecords" is the number of records in the array.
     */
    read: function(response) {
        return this.readRecords(response.features);
    },

    /**
     * APIMethod: readRecords
     *      Create a data block containing Ext.data.Records from
     *      an array of features.
     *
     * Parameters:
     * features - {Array{<OpenLayers.Feature.Vector>}}
     *
     * Returns:
     * {Object} An object with two properties. The value of the property "records"
     *      is the array of records corresponding to the features. The value of the
     *      property "totalRecords" is the number of records in the array.
     */
    readRecords : function(features) {
        var records = [];

        if (features) {
            var recordType = this.recordType, fields = recordType.prototype.fields;
            var i, lenI, j, lenJ, feature, values, field, v;
            for (i = 0, lenI = features.length; i < lenI; i++) {
                feature = features[i];
                values = {};
                if (feature.attributes) {
                    for (j = 0, lenJ = fields.length; j < lenJ; j++){
                        field = fields.items[j];
                        v = feature.attributes[field.mapping || field.name] ||
                            field.defaultValue;
                        v = field.convert(v);
                        values[field.name] = v;
                    }
                }
                values.feature = feature;
                values.state = feature.state;
                values.fid = feature.fid;

                records[records.length] = new recordType(values, feature.id);
            }
        }

        return {
            records: records,
            totalRecords: this.totalRecords != null ? this.totalRecords : records.length
        };
    }
});
