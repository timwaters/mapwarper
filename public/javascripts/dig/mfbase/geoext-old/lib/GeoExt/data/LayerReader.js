/* Copyright (C) 2008-2009 The Open Source Geospatial Foundation
 * Published under the BSD license.
 * See http://geoext.org/svn/geoext/core/trunk/license.txt for the full text
 * of the license.
 * 
 * ¹ pending approval */

/**
 * @include GeoExt/data/LayerRecord.js
 */

Ext.namespace("GeoExt", "GeoExt.data");

/**
 * Class: GeoExt.data.LayerReader
 *      LayerReader is a specific Ext.data.DataReader for converting
 *      layers into layer records, i.e. {OpenLayers.Layer} objects
 *      into {GeoExt.data.LayerRecor} objects.
 *
 * Usage example:
 * (start code)
 *         var reader = new GeoExt.data.LayerReader();
 *         var layerData = reader.readRecords(map.layers);
 *         var numRecords = layerData.totalRecords;
 *         var layerRecords = layerData.records;
 * (end)
 *
 * Inherits from:
 *  - {Ext.data.DataReader}
 */

/**
 * Constructor: GeoExt.data.LayerReader
 *      Create a layer reader. The arguments passed are similar to those
 *      passed to {Ext.data.DataReader} constructor.
 */
GeoExt.data.LayerReader = function(meta, recordType) {
    meta = meta || {};
    if(!(recordType instanceof Function)) {
        recordType = GeoExt.data.LayerRecord.create(
            recordType || meta.fields || {});
    }
    GeoExt.data.LayerReader.superclass.constructor.call(
        this, meta, recordType);
};

Ext.extend(GeoExt.data.LayerReader, Ext.data.DataReader, {

    /**
     * APIProperty: totalRecords
     * {Integer}
     */
    totalRecords: null,

    /**
     * APIMethod: readRecords
     *      From an array of {OpenLayers.Layer} objects create a data block
     *      containing {<GeoExt.data.LayerRecord>} objects.
     *
     * Parameters:
     * layers - {Array({OpenLayers.Layer})} Array of layers.
     *
     * Returns:
     * {Object} An object with two properties. The value of the property "records"
     *      is the array of layer records. The value of the property "totalRecords"
     *      is the number of records in the array.
     */
    readRecords : function(layers) {
        var records = [];
        if(layers) {
            var recordType = this.recordType, fields = recordType.prototype.fields;
            var i, lenI, j, lenJ, layer, values, field, v;
            for(i = 0, lenI = layers.length; i < lenI; i++) {
                layer = layers[i];
                values = {};
                for(j = 0, lenJ = fields.length; j < lenJ; j++){
                    field = fields.items[j];
                    v = layer[field.mapping || field.name] ||
                        field.defaultValue;
                    v = field.convert(v);
                    values[field.name] = v;
                }
                values.layer = layer;
                records[records.length] = new recordType(values, layer.id);
            }
        }
        return {
            records: records,
            totalRecords: this.totalRecords != null ? this.totalRecords : records.length
        };
    }
});
