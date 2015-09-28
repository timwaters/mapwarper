namespace :warper do
  namespace :wikimaps do
    desc 'Imports all maps from a wikimedia commons category'
    task(:import_category => :environment) do
      unless ENV["category"] || ENV["user"]
        puts "usage: rake warper:wikimaps:import_category user=1 category='foo bar' "
        break
      end
      category = ENV["category"]
      puts category
      import = Import.new(:category => category)

      #  if import.valid?
      #    import.import!
      #  else
      #    puts "Invalid import. errors were: #{import.errors.messages}"
      #  end
    end #task
    
    desc "Counts the number of File items in a category."
    task(:count_category => :environment) do
      unless ENV["category"]
        puts "usage: rake warper:wikimaps:count_category category='Category:Maps of Finland' "
        break
      end
      category = ENV["category"]
      count = Import.count(category)
      
      puts "Files #{count} for #{category}"
      
    end
    
  end
  
end
