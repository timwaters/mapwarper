# BSD Licensed, Copyright (c) 2006-2008 MetaCarta, Inc.
import os, sys, time
from warnings import warn

class Cache (object):
    def __init__ (self, timeout = 30.0, stale_interval = 300.0, readonly = False, **kwargs):
        self.stale    = float(stale_interval)
        self.timeout = float(timeout)
        self.readonly = readonly
                
    def lock (self, tile, blocking = True):
        start_time = time.time()
        result = self.attemptLock(tile)
        if result:
            return True
        elif not blocking:
            return False
        while result is not True:
            if time.time() - start_time > self.timeout:
                raise Exception("You appear to have a stuck lock. You may wish to remove the lock named:\n%s" % self.getLockName(tile)) 
            time.sleep(0.25)
            result = self.attemptLock(tile)
        return True

    def getLockName (self, tile):
        return self.getKey(tile) + ".lck"

    def getKey (self, tile):
        raise NotImplementedError()

    def attemptLock (self, tile):
        raise NotImplementedError()

    def unlock (self, tile):
        raise NotImplementedError()

    def get (self, tile):
        raise NotImplementedError()

    def set (self, tile, data):
        raise NotImplementedError()
    
    def delete(self, tile):
        raise NotImplementedError()
