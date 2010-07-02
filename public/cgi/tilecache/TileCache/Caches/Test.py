from TileCache.Cache import Cache

class Test(Cache):
    """
    A Cache class which does not cache anything: useful for
    testing during development, or any other setup where 
    TileCache should not cache data. In general, using this
    with metatiles is very slow, and not recommended.
    """
    def get(self, tile):
        return None
    
    def set(self, tile, data):
        return data 
    
    def getKey(self, tile):
        return "abc"
    
    def attemptLock(self, tile):
        return True
    
    def unlock(self, tile):
        pass
