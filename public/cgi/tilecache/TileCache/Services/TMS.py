# BSD Licensed, Copyright (c) 2006-2008 MetaCarta, Inc.

from TileCache.Service import Request, Capabilities 
import TileCache.Layer as Layer

class TMS (Request):
    def parse (self, fields, path, host):
        # /1.0.0/global_mosaic/0/0/0.jpg
        parts = filter( lambda x: x != "", path.split("/") )
        if not host[-1] == "/": host = host + "/"
        if len(parts) < 1:
            return self.serverCapabilities(host)
        elif len(parts) < 2:
            return self.serviceCapabilities(host, self.service.layers)
        else:
            layer = self.getLayer(parts[1])
            if len(parts) < 3:
                return self.layerCapabilities(host, layer)
            else:
                parts[-1] = parts[-1].split(".")[0]
                tile = None
                if layer.tms_type == "google" or (fields.has_key('type') and fields['type'] == 'google'):
                    res = layer.resolutions[int(parts[2])]
                    maxY = int(
                      round(
                        (layer.bbox[3] - layer.bbox[1]) / 
                        (res * layer.size[1])
                       )
                    ) - 1
                    tile  = Layer.Tile(layer, int(parts[3]), maxY - int(parts[4]), int(parts[2]))
                else: 
                    tile  = Layer.Tile(layer, int(parts[3]), int(parts[4]), int(parts[2]))
                return tile

    def serverCapabilities (self, host):
        return Capabilities("text/xml", """<?xml version="1.0" encoding="UTF-8" ?>
            <Services>
                <TileMapService version="1.0.0" href="%s1.0.0/" />
            </Services>""" % host)

    def serviceCapabilities (self, host, layers):
        xml = """<?xml version="1.0" encoding="UTF-8" ?>
            <TileMapService version="1.0.0">
              <TileMaps>"""

        for name, layer in layers.items():
            profile = "none"
            if (layer.srs == "EPSG:4326"): profile = "global-geodetic"
            elif (layer.srs == "OSGEO:41001"): profile = "global-mercator"
            xml += """
                <TileMap 
                   href="%s1.0.0/%s/" 
                   srs="%s"
                   title="%s"
                   profile="%s" />
                """ % (host, name, layer.srs, layer.name, profile)

        xml += """
              </TileMaps>
            </TileMapService>"""

        return Capabilities("text/xml", xml)

    def layerCapabilities (self, host, layer):
        tms_type = layer.tms_type or "default"
        xml = """<?xml version="1.0" encoding="UTF-8" ?>
            <TileMap version="1.0.0" tilemapservice="%s1.0.0/">
              <!-- Additional data: tms_type is %s -->
              <Title>%s</Title>
              <Abstract>%s</Abstract>
              <SRS>%s</SRS>
              <BoundingBox minx="%.6f" miny="%.6f" maxx="%.6f" maxy="%.6f" />
              <Origin x="%.6f" y="%.6f" />  
              <TileFormat width="%d" height="%d" mime-type="%s" extension="%s" />
              <TileSets>
            """ % (host, tms_type, layer.name, layer.description, layer.srs, layer.bbox[0], layer.bbox[1],
                   layer.bbox[2], layer.bbox[3], layer.bbox[0], layer.bbox[1],
                   layer.size[0], layer.size[1], layer.format(), layer.extension)

        for z, res in enumerate(layer.resolutions):
            xml += """
                 <TileSet href="%s1.0.0/%s/%d"
                          units-per-pixel="%.20f" order="%d" />""" % (
                   host, layer.name, z, res, z)
                
        xml += """
              </TileSets>
            </TileMap>"""

        return Capabilities("text/xml", xml)


