require 'gdal-ruby/gdal'

def get_raster_extents(filename)
    raster = Gdal::Gdal.open(filename)
    dx = raster.RasterXSize
    dy = raster.RasterYSize
    x0, x_res, x_skew, y0, y_skew, y_res = raster.get_geo_transform
    [x0,  y0 + dy * y_res, x0 + dx * x_res, y0]
end

def raster_bands_count(filename)
  raster = Gdal::Gdal.open(filename)
  raster.RasterCount
end

def is_color_table_gray?(filename)
  raster = Gdal::Gdal.open(filename)
  color_table = raster.get_raster_band(1).get_color_table
  return false unless color_table
  if color_table.get_palette_interpretation == 1
    return true
  else
    return false
  end
end
