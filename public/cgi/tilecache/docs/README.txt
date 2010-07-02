=================
 Getting Started
=================

-------------------------
Cache and serve map tiles
-------------------------

:Author: labs@metacarta.com
:Copyright: (c) 2006-2008 MetaCarta, Inc.
            Distributed under the BSD license.
:Version: 2.10 
:Manual section: 8
:Manual group: GIS Utilities

Description
===========
TileCache is a BSD licensed tile caching mechanism.  The goal is to make it
easy to set up a WMS or TMS frontend to any backend data services you might be
interested in, using a pluggable caching and rendering mechanism. 

TileCache was developed by MetaCarta Labs and released to the public under a
BSD license.

The TileCache was designed as a companion to OpenLayers, the BSD licensed web
mapping interface. If you are using TileCache with OpenLayers, please read the
section of this readme which describes how to do so. For additional help with
setting up TileCache for use with OpenLayers, please feel free to stop by
#openlayers, on irc.freenode.net, or to send email to
tilecache@openlayers.org. 

Installing TileCache
====================

Generally, installing TileCache is as simple as downloading a source
distribution and unpacking it. For installation systemwide, you can also use
the Python Package Index (aka pypi or Cheeseshop) to install TileCache. Simply
type easy_install TileCache. Once this is done, you will need to install the
TileCache configuration file. A tool to do this is installed, called
tilecache_install_config.py. A full installation likely looks like::
  
  $ sudo easy_install TileCache
  ...
  Installed
  /usr/lib/python2.5/site-packages/TileCache-2.10-py2.5.egg
  
  $ sudo tilecache_install_config.py
  Successfully copied file
  /usr/lib/python2.5/site-packages/TileCache-2.10-py2.5.egg/TileCache/tilecache.cfg
  to /etc/tilecache.cfg.
  
TileCache is also available as a Debian package from the TileCache homepage.
This Debian package is designed to install on Debian etch releases or later.
This Debian package should install on Ubuntu Feisty or Gutsy.  

Running Under CGI
=================

* Extract the code to some web directory (e.g. in /var/www).
* Edit tilecache.cfg to point the DiskCache to the location you wish
  to cache tiles, and the layers to point to the map file or WMS
  server you wish to cache. On Debian, this file is in /etc/tilecache.cfg
  by default.
* Permit CGI execution in the TileCache directory.
  For example, if TileCache is to be run with Apache, the
  following must be added in your Apache configuration,   
  where /var/www/tilecache is the directory resulting from
  the code extraction. On Debian, this is typically /usr/lib/cgi-bin.
  
  ::

    <Directory /var/www/tilecache>
         AddHandler cgi-script .cgi
         Options +ExecCGI
    </Directory>

* Visit:
  
  http://example.com/yourdir/tilecache.cgi?LAYERS=basic&SERVICE=WMS
  &VERSION=1.1.1&REQUEST=GetMap&SRS=EPSG:4326&BBOX=-180,-90,0,90
  &WIDTH=256&HEIGHT=256
  
* Or visit:

  http://example.com/yourdir/tilecache.cgi/1.0.0/basic/0/0/0.png

* If you see a tile you have set up your configuration correctly. Congrats!

Non-standard Python Location
----------------------------
If your Python is not at /usr/bin/python on your system, you will need to
change the first line of tilecache.cgi to reference the location of your Python
binary. A common example is:

  ::

     #!/usr/local/bin/python

Under Apache, you might see an error message like:

  ::

    [Wed Mar 14 19:55:30 2007] [error] [client 127.0.0.1] (2)No such file or 
      directory: exec of '/www/tilecache.cgi' failed

to indicate this problem.

You can typically locate where Python is installed on your system via the
command which python.

Windows users: If you are using Windows, you should change the first line 
of tilecache.cgi to read:

  ::

    #!C:/Python/python.exe -u

C:/Python should match the location Python is installed under on your 
system. In Python 2.5, this location is C:/Python25 by default.  

Running Under mod_python
========================

* Extract the code to some web directory (e.g. /var/www).
* Edit tilecache.cfg to point the DiskCache to the location you wish
  to cache tiles, and the layers to point to the map file or WMS
  server you wish to cache
* Add the following to your Apache configuration, under a <Directory> heading:
  
  ::
  
      AddHandler python-program .py
      PythonHandler TileCache.Service 
      PythonOption TileCacheConfig /path/to/tilecache.cfg
  
* An example might look like:

  ::
  
    <Directory /var/www/tilecache/>
        AddHandler python-program .py
        PythonHandler TileCache.Service 
        PythonOption TileCacheConfig /var/www/tilecache/tilecache.cfg
    </Directory>
  
* In this example, /var/www/tilecache is the directory resulting from
  the code extraction. If you've installed this from a Debian package, the
  location of your .cfg file is probably /etc/tilecache.cfg.
* Edit tilecache.cfg to point to the location of your 'Layers' directory,
  as demonstrated inside the default tilecache.cfg.
* Visit one of the URLs described above, replacing tilecache.cgi with 
  tilecache.py
* If you see a tile you have set up your configuration correctly. Congrats!

Running Standalone under WSGI
=============================

TileCache as of version 1.4 comes with a standalone HTTP server which uses
the WSGI handler. This implementation depends on *Python Paste*, which can be
downloaded from:
  
  http://cheeseshop.python.org/pypi/Paste

For versions of Python earlier than 2.5, you will also need to install 
wsgiref:

  http://cheeseshop.python.org/pypi/wsgiref

Once you have all the prerequisites installed, simply run:

  ::
  
    python tilecache_http_server.py

This will start a webserver listening on port 8080, after which you should
be able to open:

  ::
  
    http://hostname:8080/1.0.0/basic/0/0/0.png

to see your first tile.

Running Under FastCGI
=====================

TileCache as of version 1.4 comes with a fastcgi implementation. In 
order to use this implementation, you will need to install flup, available
from:
  
  http://trac.saddi.com/flup

This implementation also depends on Python Paste, which can be downloaded 
from:
  
  http://cheeseshop.python.org/pypi/Paste

Once you have done this, you can configure your fastcgi server to use
tilecache.fcgi.

Configuring FastCGI is beyond the scope of this documentation.

Running Under IIS
=================

Installing TileCache for use with IIS requires some additional configuration.

A nice document for setting up TileCache on IIS is available from Vish's
weblog: http://viswaug.wordpress.com/2008/02/03/setting-up-tilecache-on-iis/ .
  
Configuration
=============
TileCache is configured by a config file, defaulting to tilecache.cfg.
There are several parameters to control TileCache layers that are applicable
to all layers:

 bbox
     The bounding box of the Layer. The resolutions array defaults 
     to having resolutions which are equal to the bbox divided by
     512 (two standard tiles).
 debug
     Whether to send debug output to the error.log. Defaults to "yes",
     can be set to "no"
 description
     Layer description, used in some metadata responses. Default 
     is blank.
 extension
     File extension of the layer. Used to request images from
     WMS servers, as well as when writing cache files.
 layers
     A string used to describe the layers. Typically passed directly
     to the renderer. The WMSLayer sends this in the HTTP request,
     and the MapServerLayer chooses which layer to render based on 
     this string. If no layer is provided, the layer name is used
     to fill this property.
 levels
     An integer, describing the number of 'zoom levels' or 
     scales to support. Overridden by resolutions, if passed.        
 mapfile
     The absolute file location of a mapfile. Required for
     MapServer and Mapnik layers. 
 maxResolution
     The maximum resolution. If this is set, a resolutions
     array is automatically calculated up to a number of
     levels controlled by the 'levels' option.
 metaTile
     set to "yes" to turn on metaTiling. This will request larger
     tiles, and split them up using the Python Imaging library.
     Defaults to "no".
 metaBuffer
     an integer number of pixels to request around the outside
     of the rendered tile. This is good to combat edge effects
     in various map renderers. Defaults to 10.
 metaSize
     A comma seperated pair of integers, which is used to 
     determine how many tiles should be rendered when using
     metaTiling. Default is 5,5.
 resolutions
     Comma seperate list of resolutions you want the TileCache
     instance to support.
 size
    Comma seperated set of integers, describing the width/height
    of the tiles. Defaults to 256,256 
 srs
    String describing the SRS value. Default is "EPSG:4326"          
 type
    The type of layer. Options are: WMSLayer, MapnikLayer, MapServerLayer,
    ImageLayer
 url
    URL to use when requesting images from a remote WMS server. Required
    for WMSLayer.
 watermarkImage
    The watermarkImage parameter is assigned on a per-layer basis.
    This is a fully qualified path to an image you would like to apply to each
    tile. We recommend you use a watermark image the same size as your tiles.
    If using the default tile size, you should use a 256x256 image.
    NOTE: Python Imaging Library DOES NOT support interlaced images.
 watermarkOpacity
    The watermarkOpacity parameter is assigned on a per-layer basis.
    This configures the opacity of the watermark over the tile, it is a floating
    point number between 0 and 1. Usage is optional and will otherwise default.
 extent_type
    Setting this to 'loose' will allow TileCache to generate tiles outside the
    maximum bounding box. Useful for clients that don't know when to stop
    asking for tiles.
 tms_type
    Setting this to "google" will cause tiles to switch vertical order (that
    is, following the Google style x/y pattern).

Using TileCache With OpenLayers
===============================

To run OpenLayers with TileCache the URL passed to the OpenLayers.Layer.WMS
constructor must point to the TileCache script, i.e. tilecache.cgi or
tilecache.py. As an example see the index.html file included in the TileCache
distribution.

Note: index.html assumes TileCache is set up under CGI (see above). If you set
up TileCache under mod_python you'd need to slighly modify index.html: the URL
passed to the OpenLayers.Layer.WMS constructor must point to the mod_python
script as opposed to the CGI script, so replace tilecache.cgi with
tilecache.py. Similarly, you would need to edit this URL if you were to use
TileCache with the standalone HTTP Server or FastCGI.

The most important thing to do is to ensure that the OpenLayers Layer
has the same resolutions and bounding box as your TileCache layer. You can define
the resolutions in OpenLayers via the 'resolutions' option or the 'maxResolution' 
option on the layer. The maxExtent should be defined to match the bbox parameter
of the TileCache layer. 

If you are using TileCache for overlays, you should set the 'reproject' option
on the layer to 'false'.

Using TileCache With MapServer
==============================

MapServer has a map level metadata option, labelcache_map_edge_buffer, which
is set automatically by TileCache to the metaBuffer plus five when metaTiling
is on, if it is not set in the mapfile.

If you are using MetaTiling, be aware that MapServer generates interlaced
PNG files, which PIL will not read. See 
http://mapserver.gis.umn.edu/docs/faq/pil_mapscript on how to resolve this. 

Using With Python-Mapscript
===========================

Several users have reported cases where large mapfiles combined with 
python-mapscript has caused memory leaks, which eventually lead to 
segfaults. If you are having problems with Apache/TileCache segfaults
when using python-mapscript, then you should switch to using a WMS
Layer instead of a MapServer Layer.

Seeding your TileCache
======================

The tilecache_seed.py utility will seed tiles in a cache automatically. You will
need to have TileCache set up in one of the previously described configurations.

Usage
-----

     tilecache_seed.py [options] <layer> [<zoom start> <zoom stop>]

Options
-------
  --version             show program's version number and exit
  -h, --help            show this help message and exit
  -f, --force           force recreation of tiles even if they are already in
                        cache
  -b BBOX, --bbox=BBOX  restrict to specified bounding box
  -p PADDING, --pading=PADDING
                        extra margin tiles to seed around target area.
                        Defaults to 0 (some edge tiles might be missing).
                        A value of 1 ensures all tiles will be created, but
                        some tiles may be wholly outside your bbox                        
                        
Arguments
---------

    layer 
       same layer name that is in the tilecache.cfg
    zoom start
       Zoom level to start the process
    zoom end
       Zoom level to end the process

Seeding by center point and radius
----------------------------------
 
If called without zoom level arguments, tilecache_seed.py will assume
that it needs to read a list of points and radii from standard input, 
in the form:

  ::
  
        <lat>,<lon>,<radius>
        <lat>,<lon>,<radius> 
        <lat>,<lon>,<radius>
        <lat>,<lon>,<radius>
        <ctrl + d>

The format of this file is:

  lon
    the position(s) to seed longitude
  lat
    the position(s) to seed latitude
  radius
    the radius around the lon/lat to seed in degrees

Examples
--------

An example with zoom levels 5 through 12 and ~2 extra tiles around each zoom level would be like:

    ::
 
      $ tilecache_seed.py Zip_Codes 5 12 "-118.12500,31.952162238,-116.015625,34.3071438563" 2

The bbox can be dropped and defaults to world lonlat(-180,-90,180,90):

    ::

      $ tilecache_seed.py Zip_Codes 0 9
 

In center point/radius mode, the zoom level range is not specifiable from the
command-line. An example usage might look like:

     ::

       $ tilecache_seed.py Zip_Codes
       -118.12500,31.952162238,0.05
       -121.46327,32.345345645,0.08
       <Ctrl+D>

... the seeding will then commence ...

Cleaning your TileCache
=======================

The tilecache_clean.py utility will remove the least recently accessed
tiles from a cache, down to a specified size.

Usage
-----
    tilecache_clean.py [options] <cache_location>

Options
-------
    --version             show program's version number and exit
    -h, --help            show this help message and exit
    -s SIZE, --size=SIZE  Maximum cache size, in megabytes.
    -e ENTRIES, --entries=ENTRIES
                          Maximum cache entries. This limits the
                          amount of memory that will be used to store
                          information about tiles to remove.
     
Notes
-----
The --entries option to tilecache_clean.py is optional, and is used to regulate
how much memory it uses to do its bookkeeping. The default value of 1 million
will hopefully keep RAM utilization under about 100M on a 32-bit x86 Linux
machine. If tilecache_clean.py doesn't appear to be keeping your disk cache
down to an appropriate size, try upping this value.

tilecache_clean.py is designed to be run from a cronjob like so:

  ::

    00 05 * * *  /usr/local/bin/tilecache_clean.py -s500 /var/www/tilecache

Note that, on non-POSIX operating systems (particularly Windows),
tilecache_clean.py measures file sizes, and not disk usage. Because most
filesystems use entire file blocks for files smaller than a block, running du
-s or similar on your disk cache after a cleaning may still return a total
cache size larger than you expect.

TroubleShooting
===============

Occasionally, for some reason, when using meta tiles, your server may leave
behind lock files. If this happens, there will be files in your cache directory
with the extension '.lck'. If you are seeing tiles not render and taking 
multiple minutes before returning a 500 error, you may be suffering under
a stuck lock.

Removing all files with extension '.lck' from the cache directory will
resolve this problem.


SEE ALSO
========

memcached(8)

http://tilecache.org/

http://openlayers.org/

http://wiki.osgeo.org/index.php/WMS_Tiling_Client_Recommendation

http://wiki.osgeo.org/index.php/Tile_Map_Service_Specification
