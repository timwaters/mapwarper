# BSD Licensed, Copyright (c) 2008 MetaCartas, Inc.

"""
Provides a subclass of Disk Cache which saves in a simple z/x/y.extension, with
Y=0 being the top of the map, and heading down. This tile layout makes for
generation of tiles that is friendly to Google/OSM, and the opposite of TMS.
This is useful for pre-generating tiles for Google Maps which are going to be
used offline. This allows one to use TileCache in a gdal2tiles-like setup,
using the cache to write out a directory which can be used in other places.

Note that ext3 (a common Linux filesystem) will not support more than 32000
files in a directory, so if you plan to store a whole world at z15 or greater,
you should not use this cache class. (The Disk.py file is designed for this use
case.)

>>> from TileCache.Layer import Layer, Tile
>>> l = Layer("test")
>>> t = Tile(l, 14, 18, 12)
>>> c = GoogleDisk("/tmp/tilecache")
>>> c.getKey(t)
'/tmp/tilecache/test/12/14/4077.png'
"""

from TileCache.Cache import Cache
from TileCache.Caches.Disk import Disk

import os

class GoogleDisk(Disk):
    def getKey (self, tile):
        grid = tile.layer.grid(tile.z) 
        components = ( self.basedir,
                       tile.layer.name,
                       "%s" % int(tile.z),
                       "%s" % int(tile.x),
                       "%s.%s" % (int(grid[1] - 1 - tile.y), tile.layer.extension)
                       )
        filename = os.path.join( *components )
        return filename

if __name__ == "__main__":
    import doctest
    doctest.testmod()
