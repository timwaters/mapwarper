# BSD Licensed, Copyright (c) 2006-2008 MetaCarta, Inc.

import os, sys
from warnings import warn
from Client import WMS
from Service import TileCacheException

DEBUG = True

class Tile (object):
    """
    >>> l = Layer("name", maxresolution=0.019914, size="256,256")
    >>> t = Tile(l, 18, 20, 0)
    """
    __slots__ = ( "layer", "x", "y", "z", "data" )
    def __init__ (self, layer, x, y, z):
        """
        >>> l = Layer("name", maxresolution=0.019914, size="256,256")
        >>> t = Tile(l, 18, 20, 0)
        >>> t.x 
        18
        >>> t.y
        20
        >>> t.z
        0
        >>> print t.data
        None
        """
        self.layer = layer
        self.x = x
        self.y = y
        self.z = z
        self.data = None

    def size (self):
        """
        >>> l = Layer("name", maxresolution=0.019914, size="256,256")
        >>> t = Tile(l, 18, 20, 0)
        >>> t.size()
        [256, 256]
        """
        return self.layer.size

    def bounds (self):
        """
        >>> l = Layer("name", maxresolution=0.019914)
        >>> t = Tile(l, 18, 20, 0)
        >>> t.bounds()
        (-88.236288000000002, 11.959680000000006, -83.138303999999991, 17.057664000000003)
        """
        res  = self.layer.resolutions[self.z]
        minx = self.layer.bbox[0] + (res * self.x * self.layer.size[0])
        miny = self.layer.bbox[1] + (res * self.y * self.layer.size[1])
        maxx = self.layer.bbox[0] + (res * (self.x + 1) * self.layer.size[0])
        maxy = self.layer.bbox[1] + (res * (self.y + 1) * self.layer.size[1])
        return (minx, miny, maxx, maxy)

    def bbox (self):
        """
        >>> l = Layer("name", maxresolution=0.019914)
        >>> t = Tile(l, 18, 20, 0)
        >>> t.bbox()
        '-88.236288,11.95968,-83.138304,17.057664'
        """
        return ",".join(map(str, self.bounds()))

class MetaTile (Tile):
    def actualSize (self):
        """
        >>> l = MetaLayer("name")
        >>> t = MetaTile(l, 0,0,0)
        >>> t.actualSize()
        (256, 256)
        """
        metaCols, metaRows = self.layer.getMetaSize(self.z)
        return ( self.layer.size[0] * metaCols,
                 self.layer.size[1] * metaRows )

    def size (self):
        actual = self.actualSize()
        return ( actual[0] + self.layer.metaBuffer[0] * 2, 
                 actual[1] + self.layer.metaBuffer[1] * 2 )

    def bounds (self):
        tilesize   = self.actualSize()
        res        = self.layer.resolutions[self.z]
        buffer     = (res * self.layer.metaBuffer[0], res * self.layer.metaBuffer[1])
        metaWidth  = res * tilesize[0]
        metaHeight = res * tilesize[1]
        minx = self.layer.bbox[0] + self.x * metaWidth  - buffer[0]
        miny = self.layer.bbox[1] + self.y * metaHeight - buffer[1]
        maxx = minx + metaWidth  + 2 * buffer[0]
        maxy = miny + metaHeight + 2 * buffer[1]
        return (minx, miny, maxx, maxy)

class Layer (object):
    __slots__ = ( "name", "layers", "bbox", "data_extent", 
                  "size", "resolutions", "extension", "srs",
                  "cache", "debug", "description", 
                  "watermarkimage", "watermarkopacity",
                  "extent_type", "tms_type", "units", "mime_type",
                  "spherical_mercator", "metadata")
    
    config_properties = [
      {'name':'spherical_mercator', 'description':'Layer is in spherical mercator. (Overrides bbox, maxresolution, SRS, Units)', 'type': 'boolean'},
      {'name':'layers', 'description': 'Comma seperated list of layers associated with this layer.'},
      {'name':'extension', 'description':'File type extension', 'default':'png'},
      {'name':'bbox', 'description':'Bounding box of the layer grid', 'default':'-180,-90,180,90'},
      {'name':'srs', 'description':'Spatial Reference System for the layer', 'default':'EPSG:4326'},
      {'name':'data_extent', 'description':'Bounding box of the layer data. (Same SRS as the layer grid.)', 'default':"", 'type': 'map'},
    ]  
    
    def __init__ (self, name, layers = None, bbox = (-180, -90, 180, 90),
                        data_extent = None,
                        srs  = "EPSG:4326", description = "", maxresolution = None,
                        size = (256, 256), levels = 20, resolutions = None,
                        extension = "png", mime_type = None, cache = None,  debug = True, 
                        watermarkimage = None, watermarkopacity = 0.2,
                        spherical_mercator = False,
                        extent_type = "strict", units = "degrees", tms_type = "", **kwargs ):
        """Take in parameters, usually from a config file, and create a Layer.

        >>> l = Layer("Name", bbox="-12,17,22,36", debug="no")
        >>> l.bbox
        [-12.0, 17.0, 22.0, 36.0]
        >>> l.debug
        False
        
        >>> l = Layer("name", spherical_mercator="yes")
        >>> round(l.resolutions[0])
        156543.0
        """
        
        self.name   = name
        self.description = description
        self.layers = layers or name
        self.paletted = False
        
        self.spherical_mercator = spherical_mercator and spherical_mercator.lower() in ["yes", "y", "t", "true"]
        if self.spherical_mercator:
            bbox = "-20037508.34,-20037508.34,20037508.34,20037508.34"
            maxresolution = "156543.0339"
            if srs == "EPSG:4326":
                srs = "EPSG:900913"
            units = "meters"

        if isinstance(bbox, str): 
            bbox = map(float, bbox.split(","))
        self.bbox = bbox
        
        if isinstance(data_extent, str): 
            data_extent = map(float, data_extent.split(","))
        self.data_extent = data_extent or bbox
        
        if isinstance(size, str): 
            size = map(int, size.split(","))
        self.size = size
        
        self.units = units
        
        self.srs  = srs
        
        if extension.lower() == 'jpg': 
            extension = 'jpeg' # MIME
        elif extension.lower() == 'png256':
            extension = 'png'
            self.paletted = True
        self.extension = extension.lower()
        self.mime_type = mime_type or self.format() 
        
        if isinstance(debug, str):
            debug = debug.lower() not in ("false", "off", "no", "0")
        self.debug = debug
        
        self.cache = cache
        self.extent_type = extent_type
        self.tms_type = tms_type
        
        if resolutions:
            if isinstance(resolutions, str):
                resolutions = map(float,resolutions.split(","))
            self.resolutions = resolutions
        else:
            maxRes = None
            if not maxresolution:
                width  = bbox[2] - bbox[0]
                height = bbox[3] - bbox[1]
                if width >= height:
                    aspect = int( float(width) / height + .5 ) # round up
                    maxRes = float(width) / (size[0] * aspect)
                else:
                    aspect = int( float(height) / width + .5 ) # round up
                    maxRes = float(height) / (size[1] * aspect)
            else:
                maxRes = float(maxresolution)
            self.resolutions = [maxRes / 2 ** i for i in range(int(levels))]
        
        self.watermarkimage = watermarkimage
        
        self.watermarkopacity = float(watermarkopacity)
        
        self.metadata = {}

        prefix_len = len("metadata_")
        for key in kwargs:
            if key.startswith("metadata_"):
                self.metadata[key[prefix_len:]] = kwargs[key]
                
                

    def getResolution (self, (minx, miny, maxx, maxy)):
        """
        >>> l = Layer("name")
        >>> l.getResolution((-180,-90,0,90))
        0.703125
        """
        return max( float(maxx - minx) / self.size[0],
                    float(maxy - miny) / self.size[1] )

    def getClosestLevel (self, res, size = [256, 256]):
        diff = sys.maxint
        z = None
        for i in range(len(self.resolutions)):
            if diff > abs( self.resolutions[i] - res ):
                diff = abs( self.resolutions[i] - res ) 
                z = i
        return z

    def getLevel (self, res, size = [256, 256]):
        """
        >>> l = Layer("name")
        >>> l.getLevel(.703125)
        0
        """

        max_diff = res / max(size[0], size[1])
        z = None
        for i in range(len(self.resolutions)):
            if abs( self.resolutions[i] - res ) < max_diff:
                res = self.resolutions[i]
                z = i
                break
        if z is None:
            raise TileCacheException("can't find resolution index for %f. Available resolutions are: \n%s" % (res, self.resolutions))
        return z

    def getCell (self, (minx, miny, maxx, maxy), exact = True):
        """
        Returns x, y, z

        >>> l = Layer("name")
        >>> l.bbox
        (-180, -90, 180, 90)
        >>> l.resolutions[0]
        0.703125
        >>> l.getCell((-180.,-90.,0.,90.))
        (0, 0, 0)
        >>> l.getCell((-45.,-45.,0.,0.))
        (3, 1, 2)
        """
        res = self.getResolution((minx, miny, maxx, maxy))
        x = y = None

        if exact:
            z = self.getLevel(res, self.size)
        else:
            z = self.getClosestLevel(res, self.size)

        res = self.resolutions[z]
        
        if exact and self.extent_type == "strict" and not self.contains((minx, miny), res): 
            raise TileCacheException("Lower left corner (%f, %f) is outside layer bounds %s. \nTo remove this condition, set extent_type=loose in your configuration." 
                     % (minx, miny, self.bbox))
            return None

        x0 = (minx - self.bbox[0]) / (res * self.size[0])
        y0 = (miny - self.bbox[1]) / (res * self.size[1])
        
        x = int(round(x0))
        y = int(round(y0))
        
        tilex = ((x * res * self.size[0]) + self.bbox[0])
        tiley = ((y * res * self.size[1]) + self.bbox[1])
        if exact:
            if (abs(minx - tilex)  / res > 1):
                raise TileCacheException("Current x value %f is too far from tile corner x %f" % (minx, tilex))  
            
            if (abs(miny - tiley)  / res > 1):
                raise TileCacheException("Current y value %f is too far from tile corner y %f" % (miny, tiley))  
        
        return (x, y, z)

    def getClosestCell (self, z, (minx, miny)):
        """
        >>> l = Layer("name")
        >>> l.getClosestCell(2, (84, 17))
        (6, 2, 2)
        """
        res = self.resolutions[z]
        maxx = minx + self.size[0] * res
        maxy = miny + self.size[1] * res
        return self.getCell((minx, miny, maxx, maxy), False)

    def getTile (self, bbox):
        """
        >>> l = Layer("name")
        >>> l.getTile((-180,-90,0,90)).bbox()
        '-180.0,-90.0,0.0,90.0'
        """
        
        coord = self.getCell(bbox)
        if not coord: return None
        return Tile(self, *coord)

    def contains (self, (x, y), res = 0):
        """
        >>> l = Layer("name")
        >>> l.contains((0,0))
        True
        >>> l.contains((185, 94))
        False
        """
        diff_x1 = abs(x - self.bbox[0])
        diff_x2 = abs(x - self.bbox[2])
        diff_y1 = abs(y - self.bbox[1]) 
        diff_y2 = abs(y - self.bbox[3]) 
        return (x >= self.bbox[0] or diff_x1 < res) and (x <= self.bbox[2] or diff_x2 < res) \
           and (y >= self.bbox[1] or diff_y1 < res) and (y <= self.bbox[3] or diff_y2 < res)

    def grid (self, z):
        """
        Returns size of grid at a particular zoom level

        >>> l = Layer("name")
        >>> l.grid(3)
        (16.0, 8.0)
        """
        width  = (self.bbox[2] - self.bbox[0]) / (self.resolutions[z] * self.size[0])
        height = (self.bbox[3] - self.bbox[1]) / (self.resolutions[z] * self.size[1])
        return (width, height)

    def format (self):
        """
        >>> l = Layer("name")
        >>> l.format()
        'image/png'
        """
        return "image/" + self.extension
    
    def renderTile (self, tile):
        # To be implemented by subclasses
        pass 

    def render (self, tile):
        return self.renderTile(tile)

class MetaLayer (Layer):
    __slots__ = ('metaTile', 'metaSize', 'metaBuffer')
    
    config_properties = Layer.config_properties + [
      {'name':'name', 'description': 'Name of Layer'}, 
      {'name':'metaTile', 'description': 'Should metatiling be used on this layer?', 'default': 'false', 'type':'boolean'},
      {'name': 'metaSize', 'description': 'Comma seperated-pair of numbers, defininig the tiles included in a single size', 'default': "5,5"},
      {'name': 'metaBuffer', 'description': 'Number of pixels outside the metatile to include in the render request.'}
    ]  


    def __init__ (self, name, metatile = "", metasize = (5,5),
                              metabuffer = (10,10), **kwargs):
        Layer.__init__(self, name, **kwargs)
        self.metaTile    = metatile.lower() in ("true", "yes", "1")
        if isinstance(metasize, str):
            metasize = map(int,metasize.split(","))
        if isinstance(metabuffer, str):
            metabuffer = map(int, metabuffer.split(","))
            if len(metabuffer) == 1:
                metabuffer = (metabuffer[0], metabuffer[0])
        self.metaSize    = metasize
        self.metaBuffer  = metabuffer

    def getMetaSize (self, z):
        if not self.metaTile: return (1,1)
        maxcol, maxrow = self.grid(z)
        return ( min(self.metaSize[0], int(maxcol + 1)), 
                 min(self.metaSize[1], int(maxrow + 1)) )

    def getMetaTile (self, tile):
        x = int(tile.x / self.metaSize[0])
        y = int(tile.y / self.metaSize[1])
        return MetaTile(self, x, y, tile.z) 

    def renderMetaTile (self, metatile, tile):
        import StringIO, Image

        data = self.renderTile(metatile)
        image = Image.open( StringIO.StringIO(data) )

        metaCols, metaRows = self.getMetaSize(metatile.z)
        metaHeight = metaRows * self.size[1] + 2 * self.metaBuffer[1]
        for i in range(metaCols):
            for j in range(metaRows):
                minx = i * self.size[0] + self.metaBuffer[0]
                maxx = minx + self.size[0]
                ### this next calculation is because image origin is (top,left)
                maxy = metaHeight - (j * self.size[1] + self.metaBuffer[1])
                miny = maxy - self.size[1]
                subimage = image.crop((minx, miny, maxx, maxy))
                buffer = StringIO.StringIO()
                if image.info.has_key('transparency'): 
                    subimage.save(buffer, self.extension, transparency=image.info['transparency'])
                else:
                    subimage.save(buffer, self.extension)
                buffer.seek(0)
                subdata = buffer.read()
                x = metatile.x * self.metaSize[0] + i
                y = metatile.y * self.metaSize[1] + j
                subtile = Tile( self, x, y, metatile.z )
                if self.watermarkimage:
                    subdata = self.watermark(subdata)
                self.cache.set( subtile, subdata )
                if x == tile.x and y == tile.y:
                    tile.data = subdata

        return tile.data

    def render (self, tile, force=False):
        if self.metaTile:
            metatile = self.getMetaTile(tile)
            try:
                self.cache.lock(metatile)
                image = None
                if not force:
                    image = self.cache.get(tile)
                if not image:
                    image = self.renderMetaTile(metatile, tile)
            finally:
                self.cache.unlock(metatile)
            return image
        else:
            if self.watermarkimage:
                return self.watermark(self.renderTile(tile))
            else:
                return self.renderTile(tile)

    def watermark (self, img):
        import StringIO, Image, ImageEnhance
        tileImage = Image.open( StringIO.StringIO(img) )
        wmark = Image.open(self.watermarkimage)
        assert self.watermarkopacity >= 0 and self.watermarkopacity <= 1
        if wmark.mode != 'RGBA':
            wmark = wmark.convert('RGBA')
        else:
            wmark = wmark.copy()
        alpha = wmark.split()[3]
        alpha = ImageEnhance.Brightness(alpha).enhance(self.watermarkopacity)
        wmark.putalpha(alpha)
        if tileImage.mode != 'RGBA':
            tileImage = tileImage.convert('RGBA')
        watermarkedImage = Image.new('RGBA', tileImage.size, (0,0,0,0))
        watermarkedImage.paste(wmark, (0,0))
        watermarkedImage = Image.composite(watermarkedImage, tileImage, watermarkedImage)
        buffer = StringIO.StringIO()
        if watermarkedImage.info.has_key('transparency'):
            watermarkedImage.save(buffer, self.extension, transparency=compositeImage.info['transparency'])
        else:
            watermarkedImage.save(buffer, self.extension)
        buffer.seek(0)
        return buffer.read()

if __name__ == "__main__":
    import doctest
    doctest.testmod()
