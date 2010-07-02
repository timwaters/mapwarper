# BSD Licensed, Copyright (c) 2006-2008 MetaCarta, Inc.

from TileCache.Service import Request, Capabilities
import TileCache.Layer as Layer

class WorldWind (Request):
    def parse (self, fields, path, host):
        param = {}

        for key in ['t', 'l', 'x', 'y', 'request']: 
            if fields.has_key(key.upper()):
                param[key] = fields[key.upper()] 
            elif fields.has_key(key):
                param[key] = fields[key]
            else:
                param[key] = ""
        
        if param["request"] == "GetCapabilities" or param["request"] == "metadata":
            return self.getCapabilities(host + path, param)
        else:
            return self.getMap(param)

    def getMap (self, param):
        layer = self.getLayer(param["t"])
        level = int(param["l"])
        y = float(param["y"])
        x = float(param["x"])
        
        tile  = Layer.Tile(layer, x, y, level)
        return tile
    
    def getCapabilities (self, host, param):

        metadata = self.service.metadata
        if "description" in metadata:
            description = metadata["description"]
        else:
            description = ""

        formats = {}
        for layer in self.service.layers.values():
            formats[layer.format()] = 1
        formats = formats.keys()
        xml = """<?xml version="1.0" encoding="UTF-8" ?>
            <LayerSet Name="TileCache" ShowAtStartup="true" ShowOnlyOneLayers="false"> 
            """

        for name, layer in self.service.layers.items():
            if (layer.srs != "EPSG:4326"): continue
            xml += """
                <ChildLayerSet Name="%s" ShowAtStartup="false" ShowOnlyOneLayer="true">
                <QuadTileSet ShowAtStartup="true">
                  <Name>%s</Name>
                  <Description>Layer: %s</Description>
                  <DistanceAboveSurface>0</DistanceAboveSurface>
                  <BoundingBox>
                    <West><Value>%s</Value></West>
                    <South><Value>%s</Value></South>
                    <East><Value>%s</Value></East>
                    <North><Value>%s</Value></North>
                  </BoundingBox>
                  <TerrainMapped>false</TerrainMapped>
                  <!-- I have no clue what this means. -->
                  <ImageAccessor>
                    <LevelZeroTileSizeDegrees>%s</LevelZeroTileSizeDegrees>
                    <NumberLevels>%s</NumberLevels>
                    <TextureSizePixels>%s</TextureSizePixels>
                    <ImageFileExtension>%s</ImageFileExtension>
                    <ImageTileService>
                      <ServerUrl>%s</ServerUrl>
                      <DataSetName>%s</DataSetName>
                    </ImageTileService>  
                  </ImageAccessor>
                  <ExtendedInformation>
                    <Abstract>SRS:%s</Abstract>
                    <!-- WorldWind doesn't have any place to store the SRS --> 
                  </ExtendedInformation>
                </QuadTileSet>
              </ChildLayerSet>
                """ % (name, name, layer.description, float(layer.bbox[0]), float(layer.bbox[1]),
                       float(layer.bbox[2]), float(layer.bbox[3]), layer.resolutions[0] * layer.size[0], 
                       len(layer.resolutions), layer.size[0], layer.extension, host, 
                       name, layer.srs)

        xml += """
            </LayerSet>"""

        return Capabilities("text/xml", xml)


