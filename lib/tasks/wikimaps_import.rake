namespace :warper do
  namespace :wikimaps do
    desc 'Imports all maps from a wikimedia commons category'
    task(import_category: :environment) do
      unless ENV['category'] && ENV['user']
        puts "USAGE: rake warper:wikimaps:import_category user=1 category='foo bar' "
        break
      end
      category = ENV['category']
      user_id  = ENV['user'].to_i
      user = User.find(user_id)

      import = Import.new(category: category, uploader_user_id: user_id, user: user)

      if import.valid?
        import.import!({:append_layer => true, :save_layer => true})
      else
        puts "Invalid Import! Errors were: #{import.errors.messages}"
      end
    end # task

    desc 'Counts the number of File items in a category.'
    task(count_category: :environment) do
      unless ENV['category']
        puts "USAGE: rake warper:wikimaps:count_category category='Category:Maps of Finland' "
        break
      end
      category = ENV['category']
      count = Import.count(category)

      puts "#{count} Files for #{category}"
    end
  end
end
