# BSD Licensed, Copyright (c) 2006-2008 MetaCarta, Inc.
from TileCache.Cache import Cache
import time

class AWSS3(Cache):
    import_error = "Problem importing S3 support library. You must have either boto or the Amazon S3 library.\nErrors:\n * %s"
    def __init__ (self, access_key, secret_access_key, use_tms_paths = "False", **kwargs):
        self.module = None
        try:
            import boto.s3
            self.s3 = boto.s3
            self.module = "boto"
        except ImportError, E:
            exceptions = [str(E)]
            try:
                import S3
                self.s3 = S3
                self.module = "amazon"
            except Exception, E:
                exceptions.append(str(E))
                raise Exception(self.import_error % ('\n * '.join(exceptions)))
        Cache.__init__(self, **kwargs)
        self.bucket_name = "%s-tilecache" % access_key.lower() 
        if use_tms_paths.lower() in ("true", "yes", "1"):
            use_tms_paths = True
        elif use_tms_paths.lower() == "flipped":
            use_tms_paths = "google"
        self.use_tms_paths = use_tms_paths
        if self.module == "amazon":
            self.cache = self.s3.AWSAuthConnection(access_key, secret_access_key)
            self.cache.create_bucket(self.bucket_name)
        else:
            self.cache = self.s3.connection.S3Connection(access_key, secret_access_key)
            self.bucket = self.cache.create_bucket(self.bucket_name)
    
    def getBotoKey(self, key):
        boto_key = self.s3.key.Key(self.bucket)
        boto_key.key = key
        return boto_key
    
    def getKey(self, tile):
        if self.use_tms_paths == True or self.use_tms_paths == "flipped":
            grid = tile.layer.grid(tile.z) 
            y = tile.y
            if self.use_tms_paths == "flipped":
                y = int(grid[1] - 1 - tile.y)
            version = "1.0.0"
            path = "/".join(map(str, [version, tile.layer.name, tile.z, tile.x, y]))
            path = ".".join(map(str, [path, tile.layer.extension]))
        else: 
           path = "-".join(map(str, [tile.layer.name, tile.z , tile.x, tile.y]))
        return path

    def get(self, tile):
        key = self.getKey(tile)
        tile.data = self.getObject(key)
        return tile.data
    
    def getObject(self, key):
        data = None
        if self.module == "amazon":
            response = self.cache.get(self.bucket_name, key)
            if not response.object.data.startswith("<?xml"):
                data = response.object.data
        else:
            try:
                data = self.getBotoKey(key).get_contents_as_string()
            except:
                pass
            self.bucket.connection.connection.close()    
        return data
        
    def set(self, tile, data):
        if self.readonly: return data
        key = self.getKey(tile)
        self.setObject(key, data)
        return data
    
    def setObject(self, key, data):
        if self.module == "amazon":
            self.cache.put(self.bucket_name, key, self.s3.S3Object(data))
        else:
            self.getBotoKey(key).set_contents_from_string(data)
            self.bucket.connection.connection.close()    
    
    def delete(self, tile):
        key = self.getKey(tile)
        self.deleteObject(key) 
    
    def deleteObject(self, key):
        if self.module == "amazon":
            self.cache.delete(self.bucket_name, key)
        else: 
            self.getBotoKey(key).delete()
            
    def getLockName (self, tile):
        return "lock-%s" % self.getKey(tile)
    
    def attemptLock (self, tile):
        data = self.getObject(self.getLockName(tile))
        if not data:
            self.setObject(self.getLockName(tile), str(time.time() + self.timeout))
            return True
    
    def unlock (self, tile):
        self.deleteObject( self.getLockName(tile) )
    
    def keys (self, options = {}):
        if self.module == "amazon":
            return map(lambda x: x.key, 
                self.cache.list_bucket(self.bucket_name, options).entries)
        else:
            prefix = "" 
            if options.has_key('prefix'):
                prefix = options['prefix']
            response = self.bucket.list(prefix=prefix)
            keys = []
            for key in response:
                keys.append(key.key)
            return keys
            

if __name__ == "__main__":
    import sys
    from optparse import OptionParser
    parser = OptionParser(usage="""%prog [options] action    
    action is one of: 
      list_locks
      count_tiles
      show_tiles
      delete <object_key> or <list>,<of>,<keys>
      delete_tiles""")
    parser.add_option('-z', dest='zoom', help='zoom level for count_tiles (requires layer name)')  
    parser.add_option('-l', dest='layer', help='layer name for count_tiles')  
    parser.add_option('-k', dest='key', help='access key for S3')  
    parser.add_option('-s', dest='secret', help='secret access key for S3') 
    
    (options, args) = parser.parse_args()
    if not options.key or not options.secret or not args:
        parser.print_help()
        sys.exit()
    
    def create_prefix(options):
        prefix = "" 
        if options.layer:
            prefix = "%s-" % options.layer 
            if options.zoom:
                prefix = "%s%s-" % (prefix, options.zoom)
        return prefix        
    
    # Debug mode. 
    a = AWSS3(options.key, 
              options.secret)
    if args[0] == "list_locks":           
        print ','.join(a.keys({'prefix':'lock-'}))
    elif args[0] == "list_keys":
        print ','.join(a.keys())
    elif args[0] == "count_tiles" or args[0] == "show_tiles":
        opts = { 
            'prefix': create_prefix(options)
        }
        if args[0] == "show_tiles":
            print ",".join(a.keys(opts))
        else:
            print len(a.keys(opts))
    elif args[0] == "delete":
        for key in args[1].split(","):
            a.deleteObject(key)
    elif args[0] == "delete_tiles":
        opts = { 
            'prefix': create_prefix(options)
        }
        keys = a.keys(opts)
        val = raw_input("Are you sure you want to delete %s tiles? (y/n) " % len(keys))
        if val.lower() in ['y', 'yes']:
            for key in keys:
                a.deleteObject(key)
            
    else:
        parser.print_help() 
        
