
var mapPanel;

Ext.onReady(function() {
    var map = new OpenLayers.Map();
    var layer = new OpenLayers.Layer.WMS(
        "bluemarble",
        "http://sigma.openplans.org/geoserver/wms?",
        {layers: 'bluemarble'}
    );
    map.addLayer(layer);

    mapPanel = new GeoExt.MapPanel({
        title: "GeoExt MapPanel",
        renderTo: "mappanel",
        height: 400,
        width: 600,
        map: map,
        center: new OpenLayers.LonLat(5, 45),
        zoom: 4
    });
});

// functions for resizing the map panel
function mapSizeUp() {
    var size = mapPanel.getSize();
    size.width += 40;
    size.height += 40;
    mapPanel.setSize(size);
}
function mapSizeDown() {
    var size = mapPanel.getSize();
    size.width -= 40;
    size.height -= 40;
    mapPanel.setSize(size);
}

