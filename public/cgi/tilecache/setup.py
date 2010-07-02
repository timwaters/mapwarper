#!/usr/bin/env python

import sys

try:
    from setuptools import setup
except:
    from ez_setup import use_setuptools
    use_setuptools()
    from setuptools import setup

readme = file('docs/README.txt','rb').read()

classifiers = [
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: BSD License',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Topic :: Scientific/Engineering :: GIS',
]

# We'd like to let debian install the /etc/tilecache.cfg,
# but put them in tilecache/tilecache.cfg using setuptools
# otherwise. 
extra = { }
if "--debian" in sys.argv:
   extra['data_files']=[('/etc', ['tilecache.cfg'])]
   sys.argv.remove("--debian")
else:
   extra['data_files']=[('TileCache', ['tilecache.cfg'])]
    
setup(name='TileCache',
      version='2.10',
      description='a web map tile caching system',
      author='MetaCarta Labs',
      author_email='tilecache@openlayers.org',
      url='http://tilecache.org/',
      long_description=readme,
      packages=['TileCache', 'TileCache.Caches', 'TileCache.Services', 'TileCache.Layers'],
      scripts=['tilecache.cgi', 'tilecache.fcgi',
               'tilecache_seed.py', 'tilecache_install_config.py', 
               'tilecache_clean.py', 'tilecache_http_server.py'],
      zip_safe=False,
      test_suite = 'tests.run_doc_tests',
      license="BSD",
      classifiers=classifiers, 
      **extra 
     )
