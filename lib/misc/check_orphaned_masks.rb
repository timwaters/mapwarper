masked_files = Dir.glob("*.tif_masked")
count = 0
orphans = []
masked_files.each do | masked_file |
  orig_file = masked_file[0...-7]
  if File.exist? orig_file
    puts "orig exists"
  else
    puts "orig doesnt exist"
    count += 1
    orphans << masked_file
  end
end
puts "finished Count: " + count.to_s

files_string = orphans.join("' '")

command = "du -ch '#{files_string}'"


puts "Calculate disk usage size for user: #{command}"

total_size = `#{command}`.split("\n").last.split("\t").first

puts "total about to be freed: #{total_size}"
