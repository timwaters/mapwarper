/**
 * Copyright (c) 2008-2009 The Open Source Geospatial Foundation
 * 
 * Published under the BSD license.
 * See http://svn.geoext.org/core/trunk/geoext/license.txt for the full text
 * of the license.
 */

/**
 * @include GeoExt/data/LayerRecord.js
 */

/** api: (define)
 *  module = GeoExt.data
 *  class = WMSCapabilitiesReader
 *  base_link = `Ext.data.DataReader <http://extjs.com/deploy/dev/docs/?class=Ext.data.DataReader>`_
 */
Ext.namespace("GeoExt.data");

/** api: constructor
 *  .. class:: WMSCapabilitiesReader(meta, recordType)
 *  
 *      :param meta: ``Object`` Reader configuration.
 *      :param recordType: ``Array | Ext.data.Record`` An array of field
 *          configuration objects or a record object.  Default is
 *          :class:`GeoExt.data.LayerRecord`.
 *   
 *      Data reader class to create an array of
 *      :class:`GeoExt.data.LayerRecord` objects from a WMS GetCapabilities
 *      response.
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
                {name: "prefix"},
                {name: "attribution"},
                {name: "keywords"},
                {name: "metadataURLs"}
            ]
        );
    }
    GeoExt.data.WMSCapabilitiesReader.superclass.constructor.call(
        this, meta, recordType
    );
};

Ext.extend(GeoExt.data.WMSCapabilitiesReader, Ext.data.DataReader, {

    /** private: method[read]
     *  :param request: ``Object`` The XHR object which contains the parsed XML
     *      document.
     *  :return: ``Object`` A data block which is used by an ``Ext.data.Store``
     *      as a cache of ``Ext.data.Record`` objects.
     */
    read: function(request) {
        var data = request.responseXML;
        if(!data || !data.documentElement) {
            data = request.responseText;
        }
        return this.readRecords(data);
    },

    /** private: method[readRecords]
     *  :param data: ``DOMElement | Strint | Object`` A document element or XHR
     *      response string.  As an alternative to fetching capabilities data
     *      from a remote source, an object representing the capabilities can
     *      be provided given that the structure mirrors that returned from the
     *      capabilities parser.
     *  :return: ``Object`` A data block which is used by an ``Ext.data.Store``
     *      as a cache of ``Ext.data.Record`` objects.
     *  
     *  Create a data block containing Ext.data.Records from an XML document.
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
