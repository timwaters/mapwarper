namespace :import do
  desc "Import images from a directory to map"
  task :images => :environment do
    
    #configuration:

    #image extensions to work with
    include_exts = [".tif", ".gif", ".png", ".jpg", ".jpeg", ".tif.png", ".tiff"]

    #Directory that the images live in
    basedir = "/home/tim/work/misc_nypl_warper/libtiffpic/problematics"

    #fixed tags for fields for all models.
    default_title_prefix = ""
    default_description = ""
    default_publisher = ""
    default_author = ""
    default_scale = ""
    # default_published_date = These are datetimes
    # default_reprint_date = These are datetimes
    #
    #TODO optionally assign these all to a user.
    #User

    #////////////////#
    puts "Directory containing images: " + basedir

    puts
    puts "WARNING: This may slow down this computer, especially if you've a lot of images!"
    puts "Also, you should open up this rake file and alter some of the parameters before starting."
    print "Are you sure you want to continue ? [y/N] "
    break unless STDIN.gets.match(/^y$/i)
    puts
   
      puts "Importing "
      count = 0
      puts ""
      Dir.foreach(basedir) do | ourfilename |
        print '.'
        unless Map.exists?(:filename => ourfilename)
          print '+'
          map = Map.new(:title => ourfilename)
          ourfile = File.join(basedir , ourfilename)
          #map.owner = User.find(xxxx)
          File.open(ourfile) { |photo_file| map.upload = photo_file }
          #map.save
          count += 1 if map.save
          if map.errors.on(:filename)
            #should be caught, but just in case
            puts  ""
            puts "map has same name, wasn't imported" + ourfilename.to_s
         
          end        
        end if include_exts.include?(File.extname(ourfilename).to_s)
      end
      puts ""
      puts "Finished Importing. Number imported: "+ count.to_s
   
  end
end
