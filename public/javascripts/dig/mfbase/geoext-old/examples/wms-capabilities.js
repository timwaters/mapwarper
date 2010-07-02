var store;
Ext.onReady(function() {
    
    // create a new WMS capabilities store
    store = new GeoExt.data.WMSCapabilitiesStore({
        url: "data/wmscap.xml"
    });
    // load the store with records derived from the doc at the above url
    store.load();

    // create a grid to display records from the store
    var grid = new Ext.grid.GridPanel({
        title: "WMS Capabilities",
        store: store,
        columns: [
            {header: "Title", dataIndex: "title", sortable: true},
            {header: "Name", dataIndex: "name", sortable: true},
            {header: "Queryable", dataIndex: "queryable", sortable: true, width: 70},
            {id: "description", header: "Description", dataIndex: "abstract"}
        ],
        autoExpandColumn: "description",
        renderTo: "capgrid",
        height: 300,
        width: 650,
        listeners: {
            rowdblclick: mapPreview
        }
    });
    
    function mapPreview(grid, index) {
        var record = grid.getStore().getAt(index);
        var layer = record.get("layer").clone();
        layer.isBaseLayer = true; // default is false
        
        var win = new Ext.Window({
            title: "Preview: " + record.get("title"),
            width: 512,
            height: 256,
            items: [{
                xtype: "gx_mappanel",
                layers: [layer],
                extent: record.get("llbbox")
            }]
        });
        win.show();
    }

});
