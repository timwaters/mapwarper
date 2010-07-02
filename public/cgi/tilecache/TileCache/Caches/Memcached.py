# BSD Licensed, Copyright (c) 2006-2008 MetaCarta, Inc.

from TileCache.Cache import Cache
import time

class Memcached(Cache):
    def __init__ (self, servers = ['127.0.0.1:11211'], **kwargs):
        Cache.__init__(self, **kwargs)
        import memcache
        if type(servers) is str: servers = map(str.strip, servers.split(","))
        raise Exception(servers)
        self.cache = memcache.Client(servers, debug=0)
   
    def getKey(self, tile):
         return "/".join(map(str, [tile.layer.name, tile.x, tile.y, tile.z]))
        
    def get(self, tile):
        key = self.getKey(tile)
        tile.data = self.cache.get(key)
        return tile.data
    
    def set(self, tile, data):
        if self.readonly: return data
        key = self.getKey(tile)
        self.cache.set(key, data)
        return data
    
    def delete(self, tile):
        key = self.getKey(tile)
        self.cache.delete(key)

    def attemptLock (self, tile):
        return self.cache.add( self.getLockName(tile), "0", 
                               time.time() + self.timeout)
    
    def unlock (self, tile):
        self.cache.delete( self.getLockName(tile) )


