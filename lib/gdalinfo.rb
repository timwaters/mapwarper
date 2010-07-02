require 'gdal/gdal'

def get_raster_extents (filename)
    raster = Gdal::Gdal.open(filename)
    dx = raster.RasterXSize
    dy = raster.RasterYSize
    x0, x_res, x_skew, y0, y_skew, y_res = raster.get_geo_transform
    [x0,  y0 + dy * y_res, x0 + dx * x_res, y0]
end
