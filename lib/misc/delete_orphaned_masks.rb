#
# Deletes orphaned masked files. Run it in the src directory
#

masked_files = Dir.glob("*.tif_masked")
count = 0
orphans = []
masked_files.each do | masked_file |
  orig_file = masked_file[0...-7]
  if File.exist? orig_file
    
  else
    puts "orig doesnt exist, deleting"
    File.delete(masked_file)
    count += 1
    orphans << masked_file
  end
end

puts "finished Count: " + count.to_s
