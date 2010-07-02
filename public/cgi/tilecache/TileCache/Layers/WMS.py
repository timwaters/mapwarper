# BSD Licensed, Copyright (c) 2006-2008 MetaCarta, Inc.

from TileCache.Layer import MetaLayer
import TileCache.Client as WMSClient

class WMS(MetaLayer):
    config_properties = [
      {'name':'name', 'description': 'Name of Layer'}, 
      {'name':'url', 'description': 'URL of Remote Layer'},
      {'name':'user', 'description': 'Username of remote server: used for basic-auth protected backend WMS layers.'},
      {'name':'password', 'description': 'Password of remote server: Use for basic-auth protected backend WMS layers.'},
    ] + MetaLayer.config_properties  
     
    def __init__ (self, name, url = None, user = None, password = None, **kwargs):
        MetaLayer.__init__(self, name, **kwargs) 
        self.url = url
        self.user = user
        self.password = password

    def renderTile(self, tile):
        wms = WMSClient.WMS( self.url, {
          "bbox": tile.bbox(),
          "width": tile.size()[0],
          "height": tile.size()[1],
          "srs": self.srs,
          "format": self.mime_type,
          "layers": self.layers,
        }, self.user, self.password)
        tile.data, response = wms.fetch()
        return tile.data 
