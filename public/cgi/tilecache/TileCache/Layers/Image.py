# BSD Licensed, Copyright (c) 2006-2008 MetaCarta, Inc.

from TileCache.Layer import MetaLayer

class Image(MetaLayer):
    """The ImageLayer allows you to set up any image file in TileCache.
       All you need is an image, and a geographic bounds (filebounds),
       Which is passed in as a single, comma seperated string in the form 
       minx,miny,maxx,maxy."""
    
    config_properties = [
      {'name':'name', 'description': 'Name of Layer'}, 
      {'name':'file', 'description': 'Location of PIL-readable file.'},
    ] + MetaLayer.config_properties 
    
    def __init__ (self, name, file = None, filebounds = "-180,-90,180,90",
                              transparency = False, scaling = "nearest", **kwargs):
        import PIL.Image as PILImage
        
        MetaLayer.__init__(self, name, **kwargs) 
        
        self.file = file
        self.filebounds  = map(float,filebounds.split(","))
        self.image = PILImage.open(self.file)
        self.image_size = self.image.size
        self.image_res = [(self.filebounds[2] - self.filebounds[0]) / self.image_size[0], 
                    (self.filebounds[3] - self.filebounds[1]) / self.image_size[1]
                   ]
        self.scaling = scaling.lower()
        if isinstance(transparency, str):
            transparency = transparency.lower() in ("true", "yes", "1")
        self.transparency = transparency

    def renderTile(self, tile):
        import PIL.Image as PILImage 
        import StringIO
        bounds = tile.bounds()
        size = tile.size()
        min_x = (bounds[0] - self.filebounds[0]) / self.image_res[0]   
        min_y = (self.filebounds[3] - bounds[3]) / self.image_res[1]
        max_x = (bounds[2] - self.filebounds[0]) / self.image_res[0]   
        max_y = (self.filebounds[3] - bounds[1]) / self.image_res[1]
        if self.scaling == "bilinear":
            scaling = PILImage.BILINEAR
        elif self.scaling == "bicubic":
            scaling = PILImage.BICUBIC
        elif self.scaling == "antialias":
            scaling = PILImage.ANTIALIAS
        else:
            scaling = PILImage.NEAREST

        crop_size = (max_x-min_x, max_y-min_y)
        if min(min_x, min_y, max_x, max_y) < 0:
            if self.transparency and self.image.mode in ("L", "RGB"):
                self.image.putalpha(PILImage.new("L", self.image_size, 255));
            sub = self.image.transform(crop_size, PILImage.EXTENT, (min_x, min_y, max_x, max_y))
        else:
            sub = self.image.crop((min_x, min_y, max_x, max_y));
        if crop_size[0] < size[0] and crop_size[1] < size[1] and self.scaling == "antialias":
            scaling = PILImage.BICUBIC
        sub = sub.resize(size, scaling)

        buffer = StringIO.StringIO()
        if self.image.info.has_key('transparency'):
            sub.save(buffer, self.extension, transparency=self.image.info['transparency'])
        else:
            sub.save(buffer, self.extension)

        buffer.seek(0)
        tile.data = buffer.read()
        return tile.data 
