require 'faraday'
require 'json'

ZIPCODES = JSON.parse(Faraday.get('https://raw.githubusercontent.com/millbj92/US-Zip-Codes-JSON/master/USCities.json').body)
FIND_MAILBOXES_URL = 'https://tools.usps.com/UspsToolsRestServices/rest/POLocator/findLocations'
MAILBOXES = {}

threads = []

def hydrate_mail_boxes(zipcode, state)
  begin
    c = Faraday.new(FIND_MAILBOXES_URL)

    resp = c.post(
      FIND_MAILBOXES_URL, 
      {
        max_distance: 100,
        requestServices: 'bluebox',
        requestType: 'collectionbox',
        requestZipCode: zipcode.to_s
      }.to_json,
      'Content-Type' => 'application/json;charset=UTF-8') 

    if resp.status == 200 
      resp = JSON.parse(resp.body)
      resp['locations'].each do |l|
        MAILBOXES[l['locationID']] ||= l
      end
    else
      puts "skipping zipcode #{zipcode}, state: #{state}, status code: #{resp.status}"

      if resp.status == 403
        sleep 60
        raise
      end
    end
  rescue => e
    puts "retrying 403"
    retry
  end
end

ZIPCODES.reject do |obj|
  obj['state'] == 'VI' || obj['state'] == "PR" || obj['zip_code'] < 10000
end.each_with_index do |obj, n|
  if n % 10 == 0
    puts "#{Time.now.strftime('%m-%e-%y %H:%M')} processed #{n} zipcodes, have #{MAILBOXES.keys.length} mailboxes"
  end


  if threads.length >= 2
    threads.map(&:join)
    threads.clear
  end

  threads << Thread.new do
    hydrate_mail_boxes(obj['zip_code'], obj['state'])
  end
end

File.write("data/#{Time.now.strftime('%m-%e-%y')}.json", MAILBOXES.values.to_json)
