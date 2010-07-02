var doc = (new OpenLayers.Format.XML).read(
    '<?xml version="1.0" encoding="UTF-8"?>'+
    '<!DOCTYPE WMS_DescribeLayerResponse SYSTEM "http://demo.opengeo.org/geoserver/schemas/wms/1.1.1/WMS_DescribeLayerResponse.dtd">'+
    '<WMS_DescribeLayerResponse version="1.1.1">'+
        '<LayerDescription name="topp:states" wfs="http://demo.opengeo.org/geoserver/wfs/WfsDispatcher?">'+
            '<Query typeName="topp:states"/>'+
        '</LayerDescription>'+
        '<LayerDescription name="topp:bluemarble" wfs="http://demo.opengeo.org/geoserver/wfs/WfsDispatcher?">'+
        '</LayerDescription>'+
    '</WMS_DescribeLayerResponse>'
);
