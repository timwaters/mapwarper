# Map Warper

Mapwarper is an open source map geo-rectification, warping and georeferencing application.
It enables a user to upload an image, a scanned map or aerial photo for example, and by placing control points on a reference map and the image, to warp it, to stretch it to fit.

![Map Warper screenshot of main interface](/app/assets/images/Screenshot_MapWarper.png?raw=true "Map Warper screenshot of main interface")

The application can be seen in use at http://mapwarper.net for public use and in library setting at http://maps.nypl.org

The application is a web based crowdsourced geospatial project that enables people and organisations to collaboratively publish images of maps online and digitize and extract vector information from them.

Users rectify, warp or stretch images of historical maps with a reference basemap, assigning locations on image and map that line up with each other. Often these historical maps were in big paper books, and so for the first time they can be stitched together and shown as a whole, in digital format.

Users can crop around the maps, and join them together into mosaics (previously called layers).

By georeferencing the images, they can be warped or georectified to match the locations in space, and used in GIS software and other services. One such use of these warped maps is an application that that helps people digitize, that is, trace over the maps to extract information from them. For example, buildings in 18th Century Manhattan, details changing land use, building type etc. This application is called the Digitizer.

The application runs as a Ruby on Rails application using a number of open source geospatial libraries and technologies, including PostGIS, Mapserver, Geoserver, and GDAL tools.

The resulting maps can be exported as a PNG, GeoTIFF, WMS, Tiles, and KML for use in many different applications.

Groups of maps can be made into "mosaics" that will stitch together the composite map images.

## Features

* Upload image by file or by URL
* Find and search maps by geography
* Adding control points to maps side by side
* Crop maps
* User commenting on maps
* Align maps from similar
* Create mosaics from groups of maps
* Login via Github / Twitter / OpenStreetMap / Wikimedia Commons
* OR signup with email and password
* Export as GeoTiff, PNG, WMS, Tile, KML etc
* Preview in Google Earth
* User Groups
* Map Favourites
* Social media sharing
* Bibliographic metatadata creation and export support
* Multiple georectfication options
* Keyboard shortcuts for map controls (save point etc)
* Automagic placement of points based on transform
* Import CSV of Control points to a map
* Download CSV of control points
* API
  * JSON API Specifications
* Admin tools include
  * User statistics
  * Activity monitoring
  * User administration, disabling
  * Roles management (editor, developer, admin etc)
  * Batch Imports
* Caching of WMS and Tile via Redis
* i18n support
  * English
  * Dutch
  * Japanese

## Ruby & Rails

* Rails 4
* Ruby 2.4

## Database

* Postgresql 8.4+
* Postgis 1.5+

## Installation Dependencies

Check out the Vagrant section lower down in the readme if you want to get started quickly. Also view the lib/vagrant/provision.sh file to see what needs to get installed.

on Ubuntu 14.04 LTS

```apt-get install -y ruby ruby-dev postgresql-9.3-postgis-2.1 postgresql-server-dev-all postgresql-contrib build-essential git-core libxml2-dev libxslt1-dev imagemagick libmapserver1 gdal-bin libgdal-dev ruby-mapscript bundler nodejs```

Due to a bug with the gdal gem, you _may_ need to disable a few flags from your ruby rbconfig.rb see https://github.com/zhm/gdal-ruby/issues/4 for more information

Then install the gem files using bundler

```bundle install```

### Ubuntu 16.04 LTS

Mapwarper should work on Ubuntu 16.04 - however there are issues with the Ubuntu package of GDAL and potentially with Mapserver (if not using package Ruby, e.g. RVM)

GDAL needs to be compiled from source to ensure the gdal_rasterize bug is fixed. It should be installed locally and can exist with the package maintainers version. Then point to this newly compiled path in the application.yml file.

If rvm is being used, ruby mapscript for mapserver should be compiled from source, and then linked or installed into the path.  You can use the ubuntu package rubymapscript along with the system rub (2.3.1) without worrying about this.

See ubuntu16_installnotes for some hints as to what to do. The vagrant file and provisioning scripts should be altered, ideally.

## Configuration

Create and configure the following files

* `config/secrets.yml`
* `config/database.yml`
* `config/application.yml`

In addition have a look in `config/initializers/application_config.rb `for some other paths and variables, and `config/initializers/devise.rb `for devise and omniauth

## Database creation

Create a postgis database

` psql mapwarper_development -c "create extension postgis;" `

## Database initialization

Creating a new user

    user = User.new
    user.login = "super"
    user.email = "super@example.com"
    user.password = "your_password"
    user.password_confirmation = "your_password"
    user.save
    user.confirmed_at = Time.now
    user.save

    role = Role.find_by_name('super user')
    user = User.find_by_login('super')

    permission  = Permission.new
    permission.role = role
    permission.user = user
    permission.save

    role = Role.find_by_name('administrator')
    permission = Permission.new
    permission.role = role
    permission.user = user
    permission.save

## WMS/Tile Caching

To enable caching, install Redis and enable caching in the environment file. You may want to configure the redis.conf as appropriate to your server.
For example turning off saving to disk and setting a memory value for LRU  "maxmemory 2000mb" "maxmemory-policy allkeys-lru" keeps the redis server having 2gig and expires keys based on a least used algorithm.


## Development

Via Vagrant - There is a vagrantfile you can use this uses a provision script in lib/vagrant. Type

    vagrant up

to get and install the virtual machine - this will also install the libraries and depencies and ruby gems for mapwarper into the virtual machine. See the file in lib/vagrant/provision.sh for more details about this process

After that runs, type vagrant ssh to login and then you can

    cd /srv/mapwarper
    rails c

Create a user in the console, as shown above and then exit

    rails s -b 0.0.0.0 -p 3000

to start the server, running on port 3000

Note that there may be some hoops to jump through if you choose to use the ubuntu 16 vagrant option.

##I18n Locales / Translations

You might want to use LocaleApp to assist with translations.

See the [mapwarper](http://www.localeapp.com/projects/public?search=mapwarper) project.


## API

See README_API.md for API details
