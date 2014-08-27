#!/usr/bin/env bash

# set locale to UTF-8 compatible. apologies to non-english speakers...
#FIXME todo - remove errors with these
update-locale LANG=en_GB.utf8 LC_ALL=en_GB.utf8
locale-gen
export LANG=en_GB.utf8
export LC_ALL=en_GB.utf8

# make sure we have up-to-date packages
apt-get update

## vagrant grub-pc fix from: https://gist.github.com/jrnickell/6289943
# parameters
echo "grub-pc grub-pc/kopt_extracted boolean true" | debconf-set-selections
echo "grub-pc grub2/linux_cmdline string" | debconf-set-selections
echo "grub-pc grub-pc/install_devices multiselect /dev/sda" | debconf-set-selections
echo "grub-pc grub-pc/install_devices_failed_upgrade boolean true" | debconf-set-selections
echo "grub-pc grub-pc/install_devices_disks_changed multiselect /dev/sda" | debconf-set-selections
# vagrant grub fix
dpkg-reconfigure -f noninteractive grub-pc

# upgrade all packages
apt-get upgrade -y

# install packages as explained in INSTALL.md
apt-get install -y ruby ruby-dev \
    postgresql-9.3-postgis-2.1 postgresql-server-dev-all postgresql-contrib \
    build-essential git-core \
    libxml2-dev libxslt-dev imagemagick libmapserver1 gdal-bin libgdal-dev ruby-mapscript nodejs

#FIXME and TODO
#ruby gdal needs the build thingy set off

gem1.9.1 install bundle

## install the bundle necessary for mapwarper
pushd /srv/mapwarper
# do bundle install as a convenience
sudo -u vagrant -H bundle install
# create user and database for openstreetmap-website
db_user_exists=`sudo -u postgres psql postgres -tAc "select 1 from pg_roles where rolname='vagrant'"`
if [ "$db_user_exists" != "1" ]; then
		sudo -u postgres createuser -s vagrant
		sudo -u vagrant -H createdb -E UTF-8 -O vagrant mapwarper_dev
fi

# build and set up postgres extensions

sudo -u vagrant psql mapwarper_dev -c "create extension postgis;"


# set up sample configs
if [ ! -f config/database.yml ]; then
		sudo -u vagrant cp config/example.database.yml config/database.yml
fi
if [ ! -f config/application.yml ]; then
		sudo -u vagrant cp config/example.application.yml config/application.yml
fi
# migrate the database to the latest version
sudo -u vagrant rake db:migrate
popd
