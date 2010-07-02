var mapPanel;

Ext.onReady(function() {
    new Ext.Window({
        title: "GeoExt MapPanel Window",
        height: 400,
        width: 600,
        layout: "fit",
        items: [{
            xtype: "gx_mappanel",
            id: "mappanel",
            layers: [new OpenLayers.Layer.WMS(
                "bluemarble",
                "http://sigma.openplans.org/geoserver/wms?",
                {layers: 'bluemarble'}
            )],
            extent: "-5,35,15,55"
        }]
    }).show();
    
    mapPanel = Ext.getCmp("mappanel");
});
