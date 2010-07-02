var map;

function init() {
//    OpenLayers.ImgPath = "../../javascripts/openlayers/img/"
   var mds = new OpenLayers.Control.MouseDefaults();
    mds.defaultDblClick = function() {
        return true;
    };

    map = new OpenLayers.Map('map',  
    { controls: [mds, new OpenLayers.Control.PanZoomBar()],    
        maxExtent: new OpenLayers.Bounds(0,0, image_width, image_height),
        maxResolution: 'auto', numZoomLevels: 8});

var image = new OpenLayers.Layer.WMS( title,
                    wms_url, { format: 'image/png', status: 'unwarped' } );
         
            map.addLayer(image);
 if (!map.getCenter()) map.zoomToMaxExtent();


}
