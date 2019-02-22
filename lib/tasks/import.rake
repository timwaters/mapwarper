#RAILS_ENV=development rake warper:import ID=3
namespace :warper do
  desc "starts an import rake warper:import ID=3" 
  task :import =>  :environment  do |t, args|
    import_id = ENV['ID']  || nil
    puts "Starts an import using an ID"
    puts "USAGE rake 'warper:import ID=x' where x is the ID of an import in the ready state"
    break unless import_id
    import = Import.find(import_id.to_i)
    
    puts "Target import: #{import.id} #{import.name}  using #{import.metadata_file_name}. Number of Files: #{import.file_count}"
    
    print "Are you sure you want to continue ? [y/N] "
    break unless STDIN.gets.match(/^y$/i)
    
    if import.status != :ready
      puts "import does not have ready status, instead the status is: #{import.status}"
      break
    end
    
    import.import!
 
  end
end


