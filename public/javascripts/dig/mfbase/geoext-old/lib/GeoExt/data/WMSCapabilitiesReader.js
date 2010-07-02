/**
 * Copyright (c) 2008 The Open Planning Project
 */

Ext.namespace("GeoExt.data");

/**
 * Class: GeoExt.data.WMSCapabilitiesReader
 * Data reader class to provide an array of {Ext.data.Record} objects given
 *     a WMS GetCapabilities response for use by an {Ext.data.Store}
 *     object.
 *
 * Extends:
 *  - Ext.data.DataReader
 */

/**
 * Constructor: GeoExt.data.WMSCapabilitiesReader
 * Create a new attributes reader object.
 *
 * Parameters:
 * meta - {Object} Reader configuration.
 * recordType - {Array | Ext.data.Record} An array of field configuration
 *     objects or a record object.  Default is <GeoExt.data.LayerRecord>.
 *
 * Configuration options (meta properties):
 * format - {OpenLayers.Format} A parser for transforming the XHR response
 *     into an array of objects representing attributes.  Defaults to
 *     an {OpenLayers.Format.WMSCapabilities} parser.
 */
GeoExt.data.WMSCapabilitiesReader = function(meta, recordType) {
    meta = meta || {};
    if(!meta.format) {
        meta.format = new OpenLayers.Format.WMSCapabilities();
    }
    if(!(typeof recordType === "function")) {
        recordType = GeoExt.data.LayerRecord.create(
            recordType || meta.fields || [
                {name: "name", type: "string"},
                {name: "abstract", type: "string"},
                {name: "queryable", type: "boolean"},
                {name: "formats"},
                {name: "styles"},
                {name: "llbbox"},
                {name: "minScale"},
                {name: "maxScale"},
                {name: "prefix"}
            ]
        );
    }
    GeoExt.data.WMSCapabilitiesReader.superclass.constructor.call(
        this, meta, recordType
    );
};

Ext.extend(GeoExt.data.WMSCapabilitiesReader, Ext.data.DataReader, {

    /**
     * Method: read
     * This method is only used by a DataProxy which has retrieved data from a
     *     remote server.
     *
     * Parameters:
     * request - {Object} The XHR object which contains the parsed XML
     *     document.
     * 
     * Returns:
     * {Object} A data block which is used by an {Ext.data.Store} as a cache
     *     of Ext.data.Records.
     */
    read: function(request) {
        var data = request.responseXML;
        if(!data || !data.documentElement) {
            data = request.responseText;
        }
        return this.readRecords(data);
    },

    /**
     * Method: readRecords
     * Create a data block containing Ext.data.Records from an XML document.
     *
     * Parameters:
     * data - {DOMElement | Strint | Object} A document element or XHR response
     *     string.  As an alternative to fetching capabilities data from a remote
     *     source, an object representing the capabilities can be provided given
     *     that the structure mirrors that returned from the capabilities parser.
     *
     * Returns:
     * {Object} A data block which is used by an {Ext.data.Store} as a cache of
     *     Ext.data.Records.
     */
    readRecords: function(data) {
        
        if(typeof data === "string" || data.nodeType) {
            data = this.meta.format.read(data);
        }
        var url = data.capability.request.getmap.href;
        var records = [], layer;        
        for(var i=0, len=data.capability.layers.length; i<len; i++){
            layer = data.capability.layers[i];
            if(layer.name) {
                records.push(new this.recordType(Ext.apply(layer, {
                    layer: new OpenLayers.Layer.WMS(
                        layer.title || layer.name,
                        url,
                        {layers: layer.name}
                    )
                })));
            }
        }

        return {
            totalRecords: records.length,
            success: true,
            records: records
        };

    }
});
