#!/usr/bin/env python

# BSD Licensed, Copyright (c) 2006-2008 MetaCarta, Inc.
"""This is intended to be run as a command line tool. Use --help to determine
   arguments to this program. It is a tool to keep a certain directory
   to a maximum size by removing least recently accessed files from the 
   directory."""

import sys, os, heapq, time
from optparse import OptionParser


MAX_HEAP_SIZE  = 1000000
MAX_CACHE_SIZE = 500 # MB

def walk_disk_cache (rootdir, max_entries):
    """Walk a directory structure, building a heap of up to max_entries."""
    heap = []
    cache_size = 0
    start = time.time()
    for root, dirs, files in os.walk(rootdir):
        for file in files:
            path = os.path.join(root, file)
            stat = os.stat(path)
            size = stat.st_size
            if hasattr(stat, 'st_blocks'):
                size = stat.st_blocks * stat.st_blksize
            # strip off rootdir to keep RAM use down
            path = path[len(rootdir):]
            heapq.heappush(heap, (stat.st_atime, size, path))
            cache_size += size
            del heap[max_entries:]
    return heap, cache_size

def clean_disk_cache (rootdir, max_size, max_entries):
    """Remove files from directory until its size is less than max_size (which
       is megabytes). Up to max_entries will be removed per-run."""  
    heap, cache_size = walk_disk_cache(rootdir, max_entries)
    max_size <<= 20 # megabytes
    print "Cache entries found: %d" % len(heap) 
    removed_files = 0
    while heap and cache_size > max_size:
        atime, size, path = heapq.heappop(heap)
        cache_size -= size
        path = rootdir + path
        try:
            os.unlink(path)
            removed_files += 1
        except OSError, e:
            print >>sys.stderr, "Error removing tile %s: %s" % (path, e)
    print "Removed %d files." % removed_files    

if __name__ == "__main__":
    
    usage = "usage: %prog [options] <cache_location>"
    
    parser = OptionParser(usage=usage, version="%prog 1.0")
    parser.add_option("-s", "--size", action="store", type="int", 
                      dest="size", default = MAX_CACHE_SIZE,
                      help="Maximum cache size, in megabytes.")
    parser.add_option("-e", "--entries", action="store", type="int",
                      dest="entries", default=MAX_HEAP_SIZE,
                      help="""Maximum cache entries. This limits the 
                            amount of memory that will be used to store
                            information about tiles to remove.""")
                            
    (options, args) = parser.parse_args()
    
    if not len(args):
        parser.error("Missing required cache_location argument.")
    
    clean_disk_cache(args[0], options.size, options.entries)
