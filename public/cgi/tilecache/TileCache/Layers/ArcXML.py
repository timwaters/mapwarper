# BSD Licensed, Copyright (c) 2006-2008 MetaCarta, Inc.

"""
ArcXML support. This layer will make requests to an ArcIMS server.
"""

from TileCache.Layer import MetaLayer
from TileCache.Service import TileCacheException

import urllib
import xml.dom.minidom as m

class ArcXML(MetaLayer):
    config_properties = [
      {'name':'name', 'description': 'Name of Layer'}, 
      {'name':'url', 'description': 'URL of Remote Layer'},
      {'name':'layers', 'description': 'Comma seperated list of layers associated with this layer.'},
      {'name':'off_layers', 'description': 'Comma-seperated layers to turn on'},
      {'name':'projection', 'description': 'WKT String, or, if the string starts with "@", a file containing a WKT string.'}
    ] + MetaLayer.config_properties 
    
    def __init__ (self, name, url = None, off_layers = "", 
                  projection = None, **kwargs):
        """
        Accepts projection in one of two forms: 
         * Raw string
         * String beginning with @, in which case string is treated as filename
        """ 
        MetaLayer.__init__(self, name, **kwargs) 
        self.url = url
        self.off_layers = off_layers
        self.projection = None
        if projection is not None:
            if projection.startswith("@"):
                self.projection = open(projection[1:]).read()
            else:
                self.projection = projection

    def gen_xml(self, tile):
        """
        >>> from TileCache.Layer import Tile

        >>> l = ArcXML("foo", projection="fooproj")
        >>> xml = l.gen_xml(Tile(l, 0,0,0))
        >>> print xml.replace("\\n", "")
        <?xml version="1.0" encoding="UTF-8" ?><ARCXML version="1.1"><REQUEST><GET_IMAGE><PROPERTIES><ENVELOPE minx="-180.0" miny="-90.0" maxx="0.0" maxy="90.0" /><FEATURECOORDSYS string="fooproj"/><FILTERCOORDSYS string="fooproj"/><IMAGESIZE height="256" width="256" /><LAYERLIST ><LAYERDEF id="foo" visible="true" /></LAYERLIST></PROPERTIES></GET_IMAGE></REQUEST></ARCXML>
        >>> doc = m.parseString(xml)
        >>> feat_coord_sys = doc.getElementsByTagName("FEATURECOORDSYS")
        >>> len(feat_coord_sys)
        1
        >>> feat_coord_sys[0].getAttribute("string")
        u'fooproj'
        
        >>> l = ArcXML("foo")
        >>> xml = l.gen_xml(Tile(l, 0,0,0))
        >>> doc = m.parseString(xml)
        >>> feat_coord_sys = doc.getElementsByTagName("FEATURECOORDSYS")
        >>> len(feat_coord_sys)
        0

        >>> import os
        >>> f = open('tmp_tc_test_file', 'w')
        >>> f.write('foo<>"][')
        >>> f.close()
        >>> l = ArcXML("foo", projection="@tmp_tc_test_file")
        >>> xml = l.gen_xml(Tile(l, 0,0,0))
        >>> doc = m.parseString(xml)
        >>> feat_coord_sys = doc.getElementsByTagName("FEATURECOORDSYS")
        >>> feat_coord_sys[0].toxml()
        u'<FEATURECOORDSYS string="foo&lt;&gt;&quot;]["/>'
        >>> os.unlink("tmp_tc_test_file")

        """
        layers = []
        off_layers = []
        for layer_id in self.layers.split(","):
            if layer_id.strip():
                layers.append('<LAYERDEF id="%s" visible="true" />' % layer_id)
        for layer_id in self.off_layers.split(","):
            if layer_id.strip():
                off_layers.append('<LAYERDEF layer_id="%s" visible="false" />' % layer_id)
        bbox = tile.bounds()
        projection_text = ""
        if self.projection:
            doc = m.Document()
            feat = doc.createElement("FEATURECOORDSYS")
            feat.setAttribute("string", self.projection)
            projection_text = "%s\n%s" % (
                   feat.toxml(), feat.toxml().replace("FEATURE", "FILTER"))
        return """<?xml version="1.0" encoding="UTF-8" ?>
<ARCXML version="1.1">
<REQUEST>
<GET_IMAGE>
<PROPERTIES>
<ENVELOPE minx="%s" miny="%s" maxx="%s" maxy="%s" />
%s
<IMAGESIZE height="%s" width="%s" />
<LAYERLIST >
%s
%s
</LAYERLIST>
</PROPERTIES>
</GET_IMAGE>
</REQUEST>
</ARCXML>""" % (bbox[0], bbox[1], bbox[2], bbox[3], 
                projection_text, tile.size()[0], tile.size()[1], 
                "\n".join(layers), "\n".join(off_layers))

    def renderTile(self, tile):
        xml = self.gen_xml(tile)
        try:
            xmldata = urllib.urlopen(self.url, xml).read()
        except Exception, error:
            raise TileCacheException("Error fetching URL. Exception was: %s\n Input XML:\n %s " % (error, xml))
            
        try:
            doc = m.parseString(xmldata)
            img_url = doc.getElementsByTagName("OUTPUT")[0].attributes['url'].value
        except Exception, error:
            raise TileCacheException("Error fetching URL. Exception was: %s\n Output XML: \n%s\n\nInput XML:\n %s " % (error, xmldata, xml))
        tile.data = urllib.urlopen(img_url).read()
        return tile.data 
