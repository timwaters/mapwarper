Building GeoExt
===============

This directory contains configuration files necessary for building GeoExt
(and ExtJS).  The build configuration is intended for use with the jsbuild
utility included in JSTools (http://projects.opengeo.org/jstools).

Brief instructions
------------------

Install JSTools.

    $ easy_install http://svn.opengeo.org/jstools/trunk/

Change into the core/trunk/build directory.

    $ cd core/trunk/geoext/build

Run jsbuild.

    $ jsbuild full.cfg
    
For more complete instructions on building GeoExt, see the documentation
on the project website: http://www.geoext.org/trac/geoext/wiki/builds.
