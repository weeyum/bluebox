require 'json'

if ARGV.length != 2 
  puts "2 arguments required"
  return
end

def parse_file(filepath)
  return JSON.parse(File.read(filepath))
end

first = parse_file(ARGV[0])
second = parse_file(ARGV[1])

if first.keys == second.keys
  puts "files are the same"

  return
end


if first.keys.length >= second.keys.length
  puts "#{ARGV[0]} has more or equal mailboxes than #{ARGV[1]} by #{first.keys.length - second.keys.length}"
  sleep 5
  puts "\nthese are the missing mailboxes:\n"
  diff = first.keys - second.keys

  diff.each do |key|
    item = first[key]
    puts "\t #{item['locationID']} | #{item['state']} | #{item['address1']}, #{item['city']} #{item['state']}"
  end
else 
  puts "#{ARGV[0]} has less mailboxes than #{ARGV[1]} by #{second.keys.length - first.keys.length}"
  sleep 5
  puts "\nthese are the missing mailboxes:\n"
  diff = second.keys - first.keys

  diff.each do |key|
    item = second[key]
    puts "\t #{item['locationID']} | #{item['state']} | #{item['address1']}, #{item['city']} #{item['state']}"
  end
end