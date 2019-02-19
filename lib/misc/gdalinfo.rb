def get_raster_extents(filename)
  stdin, stdout, sterr = Open3::popen3("#{GDAL_PATH}gdalinfo", "#{filename}")
  info = stdout.readlines.to_s
  stringLW,west,south = info.match(/Lower Left\s+\(\s*([-.\d]+),\s+([-.\d]+)/).to_a
  stringUR,east,north = info.match(/Upper Right\s+\(\s*([-.\d]+),\s+([-.\d]+)/).to_a
  [west.to_f,south.to_f,east.to_f,north.to_f]
end

def raster_bands_count(filename)
  stdin, stdout, sterr = Open3::popen3("#{GDAL_PATH}gdalinfo", "#{filename}")
  info = stdout.readlines
  bands = info.select{|line| line.encode("utf-8", replace: nil).match(/^Band\s\d/) }

  bands.size
end