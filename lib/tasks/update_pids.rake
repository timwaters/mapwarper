# id	title	upload_filename	PID
# 2	Crib point	Aberfeldy_Tp_LOImp5001.jpg	9600A5C6-F3E0-11EA-BE8C-B304ECE80840
namespace :warper do
  desc "Updates PIDS for map with a TAB SEPARATED TSV file" 
  task :update_pids =>  :environment  do |t, args|
   
    filename = ENV['TSV_FILE'] 
    puts "This updates existing maps with their PIDS based on a TSV file"
    puts "File hould have id,title,upload_filename,PID as headers fields"
    puts "USAGE rake warper:update_pids TSV_FILE=/home/tim/this.tsv"
    puts "Using File #{filename}"
    print "Are you sure you want to continue ? [y/N] "
    break unless STDIN.gets.match(/^y$/i)

    success = 0
    count = 0
    fails = []

    data = open(filename)
    rows = CSV.parse(data, :headers => true, :header_converters => :symbol, :col_sep => "\t", liberal_parsing: true)
    rows.by_row!
    rows.each do | row |
      #skip if there is no filename, or no pid
      next if row[:upload_filename].blank? || row[:pid].blank?
      map = Map.find_by(upload_file_name: row[:upload_filename])
      if map
        #map.update(:pid, row[:pid] )
        print "."
        success +=1 
      else
      #  puts "map #{row[:upload_filename]} not found"
        fails << row
      end
      count += 1 
    end

    fails.each do | fail |
      puts fail.inspect
    end

    puts "#{count} rows processed. #{success} maps updated pids. #{fails.count} failures"



  end
end


