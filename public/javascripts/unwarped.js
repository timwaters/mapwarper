var un_bounds;
function uinit(){
delete umap;
delete unwarped_image;
un_bounds = new OpenLayers.Bounds(0,0, unwarped_image_width, unwarped_image_height);

unwarped_init();
}

function unwarped_init() {
   var mds = new OpenLayers.Control.MouseDefaults();
    mds.defaultDblClick = function() {
        return true;
    };

if (typeof(umap) == 'undefined'){


   umap = new OpenLayers.Map('unmap',  
       { controls: [mds, new OpenLayers.Control.PanZoomBar()],     maxExtent: un_bounds,   maxResolution: 10.496, numZoomLevels: 8});
  umap.events.register("addlayer", umap, function(e){umap.zoomToMaxExtent();}); 
   var unwarped_image = new OpenLayers.Layer.WMS( title, 
       wms_url, { format: 'image/png', status: 'unwarped' } );

   umap.addLayer(unwarped_image);
 }
   if (!umap.getCenter()){
     umap.zoomToExtent(un_bounds);
   }
//umap.zoomToExtent(un_bounds);
umap.zoomToMaxExtent();

}
