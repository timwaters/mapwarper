# BSD Licensed, Copyright (c) 2006-2008 MetaCarta, Inc.

from TileCache.Layer import MetaLayer
import osgeo.gdal as gdal
import osgeo.gdal_array as gdalarray
import numpy
import PIL

class GDAL(MetaLayer):
    """
    The GDAL Layer allows you to set up any GDAL datasource in TileCache.

    Areas not covered by the image will be transparent in formats which
    support transparency. The GDAL transparency is maintained. All bands
    of an image are read from the source file at this time.

    This Layer does not support images where north is not up.

    Special effort is taken when the GeoTransform on the image is the default 
    (0.0, 1.0, 0.0, 0.0, 0.0, 1.0): In that case, the geotransform is 
    replaced with (0.0, 1.0, 0.0, self.ds.RasterYSize, 0.0, -1.0) . This allows
    one to use the GDAL layer with non-georeferenced images: Simply specify a 
    bbox=0,0,size_x,size_y, and then you can use the image in TileCache. This is
    likely a better idea than using the Image layer, if you can install GDAL,
    since GDAL may be more efficient in managing subsetting of files, especially
    geographic sized ones, due to its ability to support overviews on files it is
    reading.
    
    This layer depends on:
     * GDAL 1.5 with Python Bindings
     * PIL
     * numpy
    """
    
    config_properties = [
      {'name':'name', 'description': 'Name of Layer'}, 
      {'name':'file', 'description': 'GDAL-readable file path.'},
    ] + MetaLayer.config_properties 
    
    def __init__ (self, name, file = None, **kwargs):
        
        MetaLayer.__init__(self, name, **kwargs) 
        
        self.ds = gdal.Open(file)
        self.geo_transform = self.ds.GetGeoTransform()
        if self.geo_transform[2] != 0 or self.geo_transform[4] != 0:
            raise Exception("Image is not 'north-up', can not use.")
        if self.geo_transform == (0.0, 1.0, 0.0, 0.0, 0.0, 1.0):
            self.geo_transform = (0.0, 1.0, 0.0, self.ds.RasterYSize, 0.0, -1.0)
        size = [self.ds.RasterXSize, self.ds.RasterYSize]
        xform = self.geo_transform
        self.data_extent = [
           xform[0] + self.ds.RasterYSize * xform[2],
           xform[3] + self.ds.RasterYSize * xform[5],  
           xform[0] + self.ds.RasterXSize * xform[1],
           xform[3] + self.ds.RasterXSize * xform[4]
        ]   

    def renderTile(self, tile):
        import PIL.Image as PILImage 
        import StringIO
        bounds = tile.bounds()
        im = None
        
        # If the image is entirely outside the bounds, don't bother doing anything with it:
        # just return an 'empty' tile.
        
        if not (bounds[2] < self.data_extent[0] or bounds[0] > self.data_extent[2] or
            bounds[3] < self.data_extent[1] or bounds[1] > self.data_extent[3]):
            tile_offset_left = tile_offset_top = 0
            
            target_size = tile.size()

            off_x = int((bounds[0] - self.geo_transform[0]) / self.geo_transform[1]);
            off_y = int((bounds[3] - self.geo_transform[3]) / self.geo_transform[5]);
            width_x = int(((bounds[2] - self.geo_transform[0]) / self.geo_transform[1]) - off_x);
            width_y = int(((bounds[1] - self.geo_transform[3]) / self.geo_transform[5]) - off_y);
            
            # Prevent from reading off the sides of an image
            if off_x + width_x > self.ds.RasterXSize:
                oversize_right = off_x + width_x - self.ds.RasterXSize
                target_size = [
                   target_size[0] - int(float(oversize_right) / width_x * target_size[0]),
                   target_size[1]
                   ]
                width_x = self.ds.RasterXSize - off_x
            
            if off_x < 0:
                oversize_left = -off_x
                tile_offset_left = int(float(oversize_left) / width_x * target_size[0])
                target_size = [
                   target_size[0] - int(float(oversize_left) / width_x * target_size[0]), 
                   target_size[1],
                   ]
                width_x = width_x + off_x
                off_x = 0
            
            if off_y + width_y > self.ds.RasterYSize:
                oversize_bottom = off_y + width_y - self.ds.RasterYSize
                target_size = [
                   target_size[0],
                   target_size[1] - round(float(oversize_bottom) / width_y * target_size[1])
                   ]
                width_y = self.ds.RasterYSize - off_y
            
            
            if off_y < 0:
                oversize_top = -off_y
                tile_offset_top = int(float(oversize_top) / width_y * target_size[1])
                target_size = [
                   target_size[0], 
                   target_size[1] - int(float(oversize_top) / width_y * target_size[1]),
                   ]
                width_y = width_y + off_y
                off_y = 0

            
            bands = self.ds.RasterCount
            array = numpy.zeros((target_size[1], target_size[0], bands), numpy.uint8)
            for i in range(bands):
                array[:,:,i] = gdalarray.BandReadAsArray(self.ds.GetRasterBand(i+1), off_x, off_y, width_x, width_y, target_size[0], target_size[1])

            im = PIL.Image.fromarray(array)
        big = PIL.Image.new("RGBA", tile.size(), (0,0,0,0))
        if im:
            big.paste(im, (tile_offset_left, tile_offset_top))
        buffer = StringIO.StringIO()
        
        big.save(buffer, self.extension)

        buffer.seek(0)
        tile.data = buffer.read()
        return tile.data 
