# Settings specified here will take precedence over those in config/environment.rb
SITE_URL = "beta.mapwarper.net"
SITE_NAME = "map warper"
SITE_EMAIL = "robot@mapwarper.net"
MAPSERVER_URL = "/mapserv"  #url to the mapserv executable

#paths to directories to put various files in
#SRC_MAPS_DIR = "/var/lib/maps/src/"
#DEST_MAPS_DIR = "/var/lib/maps/maps/dest/"
#TILEINDEX_DIR = "/var/lib/maps/dest/tileindex/"

#MAX_DIMENSION =  1500
#MAX_ATTACHMENT_SIZE = 100.megabytes
#GDAL_MEMORY_LIMIT = 30 #in mb
#
#for staging.mapwarper.net ABQIAAAAUs2kl_uF_gYL9qSq4yukexSgEqVDyz1BzXtcs2sjYKHX7Ct09xQKZPVFb7DDwZR1l3CCS6uyv18asQ
#for beta.mapwarper.net
GOOGLE_MAPS_KEY="ABQIAAAAUs2kl_uF_gYL9qSq4yukexRxkxcYXm5XhASGm0Epb0TXzVu4RRQ76q3JFV3Uf57gZY19BEkCZK2xBA"
# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.

#if we want auditing in dev mode, we gotta set these to true see above# it sucks for dev. 
config.cache_classes = false
config.action_controller.perform_caching             = false


# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true


# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

#GDAL_PATH  = "/home/tim/bin/FWTools-2.0.6/bin_safe/"
#GDAL_PATH  = ""
GOOGLE_ANALYTICS_CODE = "UA-12240034-2"
GOOGLE_ANALYTICS_COOKIE_PATH = "/warper-dev/"
Yahoo_app_id = "lbQ2VNLV34EoEmxF9dguamWEFSXjI7adJ.ACHkdChT2JGmQ0Bj.jP1cF0nmh5XP3"
ADDTHIS_USER = "timwaters"
