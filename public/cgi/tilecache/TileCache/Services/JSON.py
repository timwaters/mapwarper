from TileCache.Services.TMS import TMS
from TileCache.Service import Request, Capabilities
import simplejson
class JSON(TMS):
    def parse(self, fields, path, host):
        layers = {} 
        type = "object" 
        if fields.has_key("type") and fields['type'] == "list":
            layers = []
            type = "list"    
        
        match_srs = False
        if 'srs' in fields:
            match_srs = fields['srs']
        
        for name, layer in self.service.layers.items():
            if match_srs and layer.srs != match_srs:
                continue

            data = {
              'bbox': layer.bbox,
              'data_extent': layer.data_extent,
              'resolutions': layer.resolutions,
              'metadata': layer.metadata,
              'srs': layer.srs,
              'units': layer.units,
              'name': name, 
            }
            if type == "list":
                layers.append(data)
            else:
                layers[name] = data
        obj = {'layers': layers}
        data = simplejson.dumps(obj)
        if 'callback' in fields:
            data = "%s(%s)" % (fields['callback'], data)
        return ("application/json", data) 
