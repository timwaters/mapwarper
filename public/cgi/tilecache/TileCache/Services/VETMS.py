# BSD Licensed, Copyright (c) 2006-2008 MetaCarta, Inc.

from TileCache.Service import Request, Capabilities 
import TileCache.Layer as Layer

class VETMS (Request):
    """
    Support for Virtual Earth quadkey-based URLs.  
    <host>?ve=true&layer=global_mosaic&tile=000.jpg
    """

    def parse (self, fields, path, host):
        """Take in VETMS params and return a tile."""
        for key in ['layer', 'tile']: 
            if fields.has_key(key.upper()):
                fields[key] = fields[key.upper()] 
            elif not fields.has_key(key):
                fields[key] = ""
        layer = self.getLayer(fields['layer'])
        tilenumber = str(fields['tile'])
        quadkey = tilenumber.split(".")[0]
        tile = None
        cell = self.unquad(quadkey)
        tile  = Layer.Tile(layer, cell[0], cell[1], cell[2])
        return tile

    def unquad (self, quad):
        """
        Returns x/y/z ints based on a quadkey. 

        >>> ve = VETMS({})
        >>> ve.unquad("1")
        [1, 1, 1]
        >>> ve.unquad("")
        [0, 0, 0]
        >>> ve.unquad("02")
        [0, 2, 2]
        """
        z = len(quad)
        col = int(0)
        row = int(pow(2, z)-1)
        quadint = int(0)
        for i in range (0, z):
            quadint = int(quad[i])
            tmp = int(pow(2, z-(i+1)))
            if (quadint == 1):
                col += tmp
            elif (quadint == 2):
                row -= tmp
            elif (quadint == 3):
                col += tmp
                row -= tmp
        cell = [int(col), int(row), int(z)]
        return cell

    def serverCapabilities (self, host):
        """Report capabilities for VETMS."""
        return Capabilities("text/xml", """<?xml version="1.0" encoding="UTF-8" ?>
            <Services>
                <VETileMapService version="1.0.0" href="%s?ve=true/" />
            </Services>""" % host)

