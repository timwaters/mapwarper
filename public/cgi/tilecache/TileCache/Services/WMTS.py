# BSD Licensed, Copyright (c) 2006-2008 MetaCarta, Inc.

from TileCache.Service import Request, Capabilities, TileCacheException
import TileCache.Layer as Layer

class WMTS (Request):
    meters_per_unit = { 'degrees': 111118.752,
                        'meters': 1,
                        'feet': 0.3048
                        }
    def parse (self, fields, path, host):
        for key in ['scale','layer','tilerow','tilecol']: 
            if fields.has_key(key.upper()):
                fields[key] = fields[key.upper()] 
            elif not fields.has_key(key):
                fields[key] = ""
        layer = self.getLayer(fields['layer'])
        if not layer.units:
            raise TileCacheException("No units were specified on the layer. WMTS support requires units to be defined for the layer.") 
        res =  .00028 * float(fields['scale']) / self.meters_per_unit[layer.units]
        z = layer.getLevel(res, layer.size)
        tile = None
        maxY = int(
          round(
            (layer.bbox[3] - layer.bbox[1]) / 
            (res * layer.size[1])
           )
        ) - 1
        tile  = Layer.Tile(layer, int(fields['tilecol']), maxY - int(fields['tilerow']), z)
        return tile

