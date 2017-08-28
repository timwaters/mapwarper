#!/usr/bin/env bash

VAGRANT_HOME=/home/vagrant
RUBY_VERSION=2.2.1

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
#apt-get upgrade -y

# install packages as explained in INSTALL.md
apt-get install -y ruby1.9.1 libruby1.9.1 ruby1.9.1-dev ri1.9.1 \
    postgresql-9.3-postgis-2.1 postgresql-server-dev-all postgresql-contrib \
    build-essential git-core \
    libxml2-dev libxslt-dev imagemagick libmapserver1 gdal-bin libgdal-dev ruby-mapscript nodejs


#ruby gdal needs the build Werror=format-security removed currently
sed -i 's/-Werror=format-security//g' /usr/lib/ruby/1.9.1/x86_64-linux/rbconfig.rb

# https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
apt-get install -y  \
  autoconf \
  bison \
  libffi-dev \
  libgdal-dev \
  libgdbm-dev \
  libgdbm3 \
  libncurses5-dev \
  libreadline6-dev \
  libssl-dev \
  libxslt1-dev \
  libyaml-dev \
  python-dev \
  ruby-dev \
  zlib1g-dev

# install and enable rbenv
if [[ ! -d $VAGRANT_HOME/.rbenv ]]; then
  sudo -u vagrant -H git clone https://github.com/rbenv/rbenv.git $VAGRANT_HOME/.rbenv
  echo 'export PATH="'$VAGRANT_HOME'/.rbenv/bin:$PATH"' | sudo -u vagrant tee -a $VAGRANT_HOME/.bashrc
  echo 'eval "$(rbenv init -)"' | sudo -u vagrant tee -a $VAGRANT_HOME/.bashrc
fi
if [[ ! -d $VAGRANT_HOME/.rbenv/plugins/ruby-build ]]; then
  sudo -u vagrant -H git clone https://github.com/rbenv/ruby-build.git $VAGRANT_HOME/.rbenv/plugins/ruby-build
  echo 'export PATH="'$VAGRANT_HOME'/.rbenv/plugins/ruby-build/bin:$PATH"' | sudo -u vagrant tee -a $VAGRANT_HOME/.bashrc
fi

# the local executives
RBENV=$VAGRANT_HOME/.rbenv/bin/rbenv
GEM=$VAGRANT_HOME/.rbenv/shims/gem
BUNDLE=$VAGRANT_HOME/.rbenv/shims/bundle

# get and switch ruby version
sudo -u vagrant -H $RBENV install $RUBY_VERSION
sudo -u vagrant -H $RBENV global $RUBY_VERSION
sudo -u vagrant -H $RBENV rehash

# link depended modules from global into local
sudo -u vagrant ln -s \
  /usr/lib/x86_64-linux-gnu/ruby/vendor_ruby/2.0.0/mapscript.so \
  $VAGRANT_HOME/.rbenv/versions/$RUBY_VERSION/lib/ruby/vendor_ruby/2.2.0/x86_64-linux/mapscript.so

# install module management package
# gem1.9.1 install bundle
sudo -u vagrant -H $GEM install bundler

## install the bundle necessary for mapwarper
pushd /srv/mapwarper

# do bundle install as a convenience and put the dependencies outside to accelerate `bundle exec` command
sudo -u vagrant -H $BUNDLE install --path $VAGRANT_HOME/mapwarper_dependencies

# create user and database for openstreetmap-website
db_user_exists=`sudo -u postgres psql postgres -tAc "select 1 from pg_roles where rolname='vagrant'"`
if [ "$db_user_exists" != "1" ]; then
		sudo -u postgres createuser -s vagrant
		sudo -u vagrant -H createdb -E UTF-8 -O vagrant mapwarper_development
fi

# build and set up postgres extensions

sudo -u vagrant psql mapwarper_development -c "create extension postgis;"


# set up sample configs
if [ ! -f config/database.yml ]; then
		sudo -u vagrant cp config/database.example.yml config/database.yml
fi
if [ ! -f config/application.yml ]; then
		sudo -u vagrant cp config/application.example.yml config/application.yml
fi
if [ ! -f config/secrets.yml ]; then
		sudo -u vagrant cp config/secrets.yml.example config/secrets.yml
fi

echo "now migrating database. This may take a few minutes"
# migrate the database to the latest version
sudo -u vagrant -H $BUNDLE exec rake db:migrate

popd
