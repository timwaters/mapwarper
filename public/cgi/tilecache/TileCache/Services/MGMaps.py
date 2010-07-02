# BSD Licensed, Copyright (c) 2006-2008 MetaCarta, Inc.

from TileCache.Service import Request, Capabilities
import TileCache.Layer as Layer

class MGMaps (Request):
    def parse (self, fields, path, host):
        param = {}

        for key in ['layer', 'zoom', 'x', 'y']: 
            if fields.has_key(key.upper()):
                param[key] = fields[key.upper()] 
            elif fields.has_key(key):
                param[key] = fields[key]
            else:
                param[key] = ""
        
        return self.getMap(param)

    def getMap (self, param):
        layer = self.getLayer(param["layer"])
        level = int(param["zoom"])
        level = 17 - level
        x = float(param["x"])
        y = float(param["y"])
        res = layer.resolutions[level]
        maxY = int(
          round(
            (layer.bbox[3] - layer.bbox[1]) / 
            (res * layer.size[1])
           )
        ) - 1
        tile  = Layer.Tile(layer, x, maxY - y, level)
        
        return tile

