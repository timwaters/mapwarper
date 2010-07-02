/**
 * Copyright (c) 2008 The Open Planning Project
 */

/**
 * @include GeoExt/data/WMSCapabilitiesReader.js
 */

Ext.namespace("GeoExt.data");
/**
 * Class: GeoExt.data.WMSCapabilitiesStore
 * Small helper class to make creating stores for remote WMS layer data easier.
 *     WMSCapabilitiesStore is pre-configured with a built-in
 *     {Ext.data.HttpProxy} and {GeoExt.data.WMSCapabilitiesReader}.  The
 *     HttpProxy is configured to allow caching (disableCaching: false) and uses
 *     GET.  If you require some other proxy/reader combination then you'll have
 *     to configure this with your own proxy or create a basic
 *     GeoExt.data.LayerStore and configure as needed.
 *
 * Extends:
 *  - GeoExt.data.Store
 */

/**
 * Constructor: GeoExt.data.WMSCapabilitiesStore
 * Create a new WMS capabilities store object.
 *
 * Parameters:
 * config - {Object} Store configuration.
 *
 * Configuration options:
 * format - {OpenLayers.Format} A parser for transforming the XHR response into
 *     an array of objects representing attributes.  Defaults to an
 *     {OpenLayers.Format.WMSCapabilities} parser.
 * fields - {Array | Function} Either an Array of field definition objects as
 *     passed to Ext.data.Record.create, or a Record constructor created using
 *     Ext.data.Record.create.  Defaults to ["name", "type"]. 
 */
GeoExt.data.WMSCapabilitiesStore = function(c) {
    GeoExt.data.WMSCapabilitiesStore.superclass.constructor.call(
        this,
        Ext.apply(c, {
            proxy: c.proxy || (!c.data ?
                new Ext.data.HttpProxy({url: c.url, disableCaching: false, method: "GET"}) :
                undefined
            ),
            reader: new GeoExt.data.WMSCapabilitiesReader(
                c, c.fields
            )
        })
    );
};
Ext.extend(GeoExt.data.WMSCapabilitiesStore, Ext.data.Store);
