#!/usr/bin/env bash
set -eu

# constants
VAGRANT_HOME=/home/vagrant
RUBY_VERSION=2.2.1

# make sure we have up-to-date packages
apt-get update

## vagrant grub-pc fix from: https://gist.github.com/jrnickell/6289943
# parameters
echo "grub-pc grub-pc/kopt_extracted boolean true" | sudo debconf-set-selections
echo "grub-pc grub2/linux_cmdline string" | sudo debconf-set-selections
echo "grub-pc grub-pc/install_devices multiselect /dev/sda" | sudo debconf-set-selections
echo "grub-pc grub-pc/install_devices_failed_upgrade boolean true" | sudo debconf-set-selections
echo "grub-pc grub-pc/install_devices_disks_changed multiselect /dev/sda" | sudo debconf-set-selections
# vagrant grub fix
sudo dpkg-reconfigure -f noninteractive grub-pc

# upgrade all packages
#apt-get upgrade -y

# install packages as explained in INSTALL.md
sudo apt-get install -y postgresql-9.3-postgis-2.1 postgresql-server-dev-all postgresql-contrib \
    build-essential git-core \
    libxml2-dev libxslt-dev imagemagick libmapserver1 gdal-bin libgdal-dev ruby-mapscript nodejs

#ruby gdal needs the build Werror=format-security removed currently
sudo sed -i 's/-Werror=format-security//g' /usr/lib/ruby/1.9.1/x86_64-linux/rbconfig.rb


# install RVM https://rvm.io/integration/vagrant
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
rvm install $RUBY_VERSION
rvm use $RUBY_VERSION
rvm --default use $RUBY_VERSION # これが聞かない

which ruby
which gem

# link depended modules from global into local
ln -s \
  "/usr/lib/x86_64-linux-gnu/ruby/vendor_ruby/2.0.0/mapscript.so" \
  "/usr/local/rvm/rubies/ruby-$RUBY_VERSION/lib/ruby/vendor_ruby/2.2.0/x86_64-linux/mapscript.so"
  
# install module management package
gem install bundler

## install the bundle necessary for mapwarper
pushd /srv/mapwarper

# do bundle install as a convenience and put the dependencies outside to accelerate `bundle exec` command
bundle install --path $VAGRANT_HOME/mapwarper_dependencies

# create user and database for openstreetmap-website
db_user_exists=`sudo -u postgres psql postgres -tAc "select 1 from pg_roles where rolname='vagrant'"`
if [ "$db_user_exists" != "1" ]; then
		sudo -u postgres createuser -s vagrant
		createdb -E UTF-8 -O vagrant mapwarper_development
fi

# build and set up postgres extensions

psql mapwarper_development -c "create extension postgis;"


# set up sample configs
if [ ! -f config/database.yml ]; then
		cp config/database.example.yml config/database.yml
fi
if [ ! -f config/application.yml ]; then
		cp config/application.example.yml config/application.yml
fi
if [ ! -f config/secrets.yml ]; then
		cp config/secrets.yml.example config/secrets.yml
fi

echo "now migrating database. This may take a few minutes"
# migrate the database to the latest version
bundle exec rake db:migrate
popd
