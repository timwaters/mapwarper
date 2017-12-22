namespace :warper do
  namespace :old_users do 

    desc "Returns details of old users to help plan removal of older users in system"
      ## call this like this: (note single quotes around the task name and args) rake 'warper:old_users:plan_purge[10, 2006-01-01]'

    task :plan_purge, [:limit, :created_at] => :environment do | t, args | 

      include ActiveSupport::NumberHelper

      puts "\nPlanning Old User Purge....\n"
      puts "Args were: #{args.to_hash}"
      usage = "::::::USAGE::::::\nrake warper:old_users:plan_purge['limit (int) REQUIRED', created_at (YYYY-MM-DD) REQUIRED \n\nEXAMPLE   warper:old_users:plan_purge[50,'2004-01-01'] "
     
       #check to make sure the args are filled in properly
      unless args.has_key?(:limit) &&  args.has_key?(:created_at)
        puts "no limit or created_at passed in as args"
        puts usage
        break
      end

      unless Date.strptime(args.created_at,'%Y-%m-%d')  #this should error out anyhow before we get to our check
        puts "created_at at not parsed"  
        puts usage
        break
      end

      before_created_at = Date.strptime(args.created_at,'%Y-%m-%d')

      users = User.where('own_maps_count > 0').order('own_maps_count DESC NULLS LAST').where('created_at < ?', before_created_at).limit(args.limit)
      
      eligable_users_size = 0
      file_size_sum = 0
      puts "login, email, updated_at,  created_at,  map count, filesize"

      users.each do | user |
        next if user.own_maps.where(protect: true).count > 0
        next if user.own_maps.published.count > 0
        next unless user.roles.empty?
        file_size_sum += user.upload_filesize_sum
        eligable_users_size += 1
        puts "#{user.login}, #{user.email}, #{user.updated_at.strftime("%F")}, #{user.created_at.strftime("%F")}, #{user.own_maps_count}, #{number_to_human_size(user.upload_filesize_sum)}"
      end

      puts "Eligable user count: #{eligable_users_size.size}, total file size = ", number_to_human_size(file_size_sum)

    end

  

    desc "Notifies old users about upcoming purge from the system. Sends email allowing users to log in an stop purge."

    task :notify_purge, [:limit, :created_at] => :environment do | t, args | 

      include ActiveSupport::NumberHelper

      usage = "::::::USAGE::::::\nrake 'warper:old_users:notify_purge[limit (int) REQUIRED, created_at (YYYY-MM-DD) REQUIRED]'"
      
      unless args.has_key?(:limit) &&  args.has_key?(:created_at) 
        puts "no limit or created_at  passed in as args"
        puts usage
        break
      end

      unless Date.strptime(args.created_at,'%Y-%m-%d')  #this should error out anyhow before we get to our check
        puts "created_at not parsed"  
        puts usage
        break
      end

      puts "Continue with notification?"
      break unless STDIN.gets.match(/^y$/i)


      before_created_at = Date.strptime(args.created_at,'%Y-%m-%d')
      
      users = User.where('own_maps_count > 0').order(:own_maps_count).where('created_at < ?', before_created_at).limit(args.limit)
      
      file_size_sum = 0
      puts "login, email, updated_at,  created_at,  map count, filesize"
      users.each do | user |
        next if user.own_maps.where(protect: true).count > 0
        next if user.own_maps.published.count > 0
        next unless user.roles.empty?
        file_size_sum += user.upload_filesize_sum
        
        notes =  "#{user.login}, #{user.email}, #{user.updated_at.strftime("%F")}, #{user.created_at.strftime("%F")}, #{user.own_maps_count}, #{number_to_human_size(user.upload_filesize_sum)}"
        puts notes

       warning =  UserWarning.new(:category =>"purge_notify", :status =>"open", :note => notes, :user => user)

       if warning.save
         UserMailer.old_user_notify(user).deliver_now
       else
         puts "Already notified. #{warning.errors.messages}" 
       end

      end

    end
   
  end
end
