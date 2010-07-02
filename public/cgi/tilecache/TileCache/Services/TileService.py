# BSD Licensed, Copyright (c) 2006-2008 MetaCarta, Inc.

from TileCache.Service import Request, Capabilities
import TileCache.Layer as Layer

class TileService (Request):
    def parse (self, fields, path, host):
        param = {}

        for key in ['interface', 'version', 'dataset', 'level', 'x', 'y', 'request']: 
            if fields.has_key(key.upper()):
                param[key] = fields[key.upper()] 
            elif fields.has_key(key):
                param[key] = fields[key]
            else:
                param[key] = ""
        
        return self.getMap(param)

    def getMap (self, param):
        layer = self.getLayer(param["dataset"])
        level = int(param["level"])
        y = float(param["y"])
        x = float(param["x"])
        
        tile  = Layer.Tile(layer, x, y, level)
        return tile
