# BSD Licensed, Copyright (c) 2006-2008 MetaCarta, Inc.

from TileCache.Layer import MetaLayer 

class MapServer(MetaLayer):
    
    config_properties = [
      {'name':'name', 'description': 'Name of Layer'}, 
      {'name':'mapfile', 'description': 'Location of MapServer map file.'},
    ] + MetaLayer.config_properties 
    
    def __init__ (self, name, mapfile = None, styles = "", **kwargs):
        MetaLayer.__init__(self, name, **kwargs) 
        self.mapfile = mapfile
        self.styles = styles

    def get_map(self, tile):
        # tile is unused here but might be used in a subclass
        # where the mapfile config depends on the tile extents or layer
        import mapscript
        wms = mapscript.mapObj(self.mapfile) 
        if self.metaBuffer:
            try:
                # if the metadata is already set, don't override.
                wms.getMetaData("labelcache_map_edge_buffer")
            except mapscript._mapscript.MapServerError:
                # We stick an extra buffer of 5px in there because in the case
                # of shields, we want to account for when the shield could get
                # cut even though the label that the shield is on isn't.
                buffer = -max(self.metaBuffer[0], self.metaBuffer[1]) - 5
                wms.setMetaData("labelcache_map_edge_buffer", str(buffer))
        return wms

    def get_request(self, tile):
        import mapscript
        req = mapscript.OWSRequest()
        req.setParameter("bbox", tile.bbox())
        req.setParameter("width", str(tile.size()[0]))
        req.setParameter("height", str(tile.size()[1]))
        req.setParameter("srs", self.srs)
        req.setParameter("format", self.mime_type)
        req.setParameter("layers", self.layers)
        req.setParameter("styles", self.styles)
        req.setParameter("request", "GetMap")
        return req

    def renderTile(self, tile):
        wms = self.get_map(tile)
        req = self.get_request(tile)
        wms.loadOWSParameters(req)
        mapImage = wms.draw()
        tile.data = mapImage.getBytes()
        return tile.data 
