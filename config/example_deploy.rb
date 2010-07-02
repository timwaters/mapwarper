set :application, "warper"
set :repository,  "svn repository"


# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "my.domain.org"
role :web, "my.domain.org"
role :db,  "my.domain.org", :primary => true

set :deploy_to, "/var/www/apps/mapwarper.net/"
set :use_sudo, false
set :checkout, "export"
set :user, "user"

#tasks

desc "Tasks to execute after code update"


task :after_update_code, :roles => :app do

  db_config = "#{shared_path}/config/database.yml.production"
  run "cp #{db_config} #{release_path}/config/database.yml"

  mail_config = "#{shared_path}/config/mail.rb.production"
  run "cp #{mail_config} #{release_path}/config/initializers/mail.rb"

  production_env_config = "#{shared_path}/config/production.rb.production"
  run "cp #{production_env_config} #{release_path}/config/environments/production.rb"

  %w{mapimages uploads}.each do |share|
    run "rm -rf #{release_path}/public/#{share}"
    run "mkdir -p #{shared_path}/system/#{share}"
    run "ln -nfs #{shared_path}/system/#{share} #{release_path}/public/#{share}"

  end


end

desc "Link in the production extras"
task :after_symlink do
  run "mkdir -p #{shared_path}/system/mapfiles"
  run "mkdir -p #{shared_path}/system/mapfiles/dst"
  run "mkdir -p #{shared_path}/system/mapfiles/src"

	#prob not needed...
  #    run "cp #{release_path}/db/mapfiles/test.map #{shared_path}/system/mapfiles/test.map"
  #
  #     run "cp #{release_path}/db/mapfiles/default.map #{shared_path}/system/mapfiles/default.map"
  run "rm -rf #{release_path}/db/mapfiles"
  run "ln -nfs #{shared_path}/system/mapfiles #{release_path}/db/mapfiles"

  run "rm -rf #{release_path}/db/maptileindex"
  run "ln -nfs #{shared_path}/system/maptileindex #{release_path}/db/maptileindex"

  #put the mapserv in this folder
  run "rm -rf #{release_path}/public/cgi"
  run "mkdir -p #{shared_path}/system/cgi"
  run "ln -nfs #{shared_path}/system/cgi #{release_path}/public/cgi"

end


#############################################################
#	Passenger
#############################################################

namespace :passenger do
  desc "Restart Application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

after :deploy, "passenger:restart"

