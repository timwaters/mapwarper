/* Copyright (C) 2008-2009 The Open Source Geospatial Foundation
 * Published under the BSD license.
 * See http://geoext.org/svn/geoext/core/trunk/license.txt for the full text
 * of the license.
 * 
 * pending approval */

Ext.namespace("GeoExt.data");

/**
 * Class: GeoExt.data.LayerRecord
 * A subclass of {Ext.data.Record} which provides a special record that
 * represents an {OpenLayers.Layer}. This record will always have at least a
 * layer and a title field in its data. The id of this record will be the same
 * as the id of the layer it represents.
 * 
 * Inherits from
 * - {Ext.data.Record}
 */
/**
 * Constructor: GeoExt.data.LayerRecord
 * 
 * Parameters:
 * data - {Object} data object for the record
 * id - {String} id of the record
 */
GeoExt.data.LayerRecord = Ext.data.Record.create([
    {name: "layer"},
    {name: "title", type: "string", mapping: "name"}
]);

/**
 * APIMethod: copy
 * Creates a copy of this Record.
 * 
 * Paremters:
 * id - {String} (optional) A new Record id.
 *
 * Returns:
 * {GeoExt.data.LayerRecord} A new layer record.
 */
GeoExt.data.LayerRecord.prototype.copy = function(id) {
    var layer = this.get("layer") && this.get("layer").clone();
    return new this.constructor(
        Ext.applyIf({layer: layer}, this.data),
        id || this.id
    );
};

/**
 * APIFunction: GeoExt.data.LayerRecord.create
 * Creates a constructor for a LayerRecord, optionally with additional
 * fields.
 * 
 * Parameters:
 * o - {Array} Field definition as in {Ext.data.Record.create}. Can be omitted
 *     if no additional fields are required (records will always have a
 *     {OpenLayers.Layer} layer and a {String} title field).
 *
 * Returns:
 * {Function} A specialized {<GeoExt.data.LayerRecord>} constructor.
 */
GeoExt.data.LayerRecord.create = function(o) {
    var f = Ext.extend(GeoExt.data.LayerRecord, {});
    var p = f.prototype;

    p.fields = new Ext.util.MixedCollection(false, function(field) {
        return field.name;
    });

    GeoExt.data.LayerRecord.prototype.fields.each(function(f) {
        p.fields.add(f);
    });

    if(o) {
        for(var i = 0, len = o.length; i < len; i++){
            p.fields.add(new Ext.data.Field(o[i]));
        }
    }

    f.getField = function(name) {
        return p.fields.get(name);
    };

    return f;
};
