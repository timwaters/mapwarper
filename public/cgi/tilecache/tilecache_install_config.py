#!/usr/bin/python 

"""Script to install a TileCache config from an egg installation."""  

import sys
from optparse import OptionParser

def install(dest):
    try:
        f = open(dest, "w")
    except IOError, E:
        print "Unable to open destination file %s. Perhaps you need permission to write there?\n(Error was: %s)" % (dest, E)
        sys.exit(1)
    
    try:    
        import pkg_resources
        filename = pkg_resources.resource_filename("TileCache", "tilecache.cfg")
        cfg = open(filename, "r")
    except Exception, E:
        print "Unable to open source file.\n(Error was: %s)" % (E)
        sys.exit(1)
        
    f.write(cfg.read())
    f.close()
    cfg.close()
    print "Successfully copied file %s to %s." % (filename, dest)
    
if __name__ == "__main__":
    parser = OptionParser(usage="""%prog [options] 

This script is a helper script designed to install the default TileCache
configuration when TileCache is installed from an egg.""")
    
    parser.add_option('-d', '--dest', dest="dest", help="install to FILE. Default is /etc/tilecache.cfg", default="/etc/tilecache.cfg", metavar="FILE") 
    
    (options, args) = parser.parse_args()
    install(options.dest)
