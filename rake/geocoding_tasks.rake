require 'rake'
require 'open-uri'
require 'rexml/document'

# set GOOGLE_MAPS_KEY and YAHOO_API_KEY to your own API key values
# I set mine in environment.rb

namespace :geocode do
  desc "Output the geocode all events via google geocoder"   
  task :google_geocode => :environment do
    api_key=GOOGLE_MAPS_KEY # set in environment.rb

    (Event.find :all).each do |event|

      puts "\nevent: #{event.name}"
      puts "Source Address: #{event.location}"

      xml=open("http://maps.google.com/maps/geo?q=#{CGI.escape(event.location)}&output=xml&key=#{api_key}").read
      doc=REXML::Document.new(xml)

      puts "Status: "+doc.elements['//kml/Response/Status/code'].text

      if doc.elements['//kml/Response/Status/code'].text != '200'
        puts "Unable to parse Google response for #{event.name}"
      else
        doc.root.each_element('//Response') do |response|
          response.each_element('//Placemark') do |place|      
            lng,lat=place.elements['//coordinates'].text.split(',')
          
            puts "Result Address: " << place.elements['//address'].text
            puts "  Latitude: #{lat}"
            puts "  Longitude: #{lng}"
            state=doc.root.elements['//AddressDetails/Country/AdministrativeArea/AdministrativeAreaName/'].text
            puts "  State: #{state}"
            # determine region via event.state
            region_id = case state
            when 'CA'
              if lat.to_f > 36.3219
                Region.find_by_name('NorCal').id
              else
                Region.find_by_name('SoCal').id              
              end
            when 'NV'
              if lng.to_f < -118.6846
                Region.find_by_name('NorCal').id
              else
                Region.find_by_name('Mountain').id
              end              
            when 'ME', 'NH', 'VT', 'NY', 'CT', 'RI', 'MA'
              Region.find_by_name('Northeast').id
            when 'WA', 'OR', 'ID'
              Region.find_by_name('Northwest').id
            when 'UT', 'CO', 'WY', 'MT'
              Region.find_by_name('Mountain').id
            when 'AZ', 'NM'
              Region.find_by_name('Southwest').id
            when 'TX', 'OK', 'AR', 'LA'
              Region.find_by_name('South Central').id
            when 'KS', 'MO', 'NE', 'IA'
              Region.find_by_name('Central').id
            when 'SD', 'ND', 'MN'
              Region.find_by_name('North Central').id
            when 'WI', 'IL', 'IN', 'OH', 'MI', 'KY'
              Region.find_by_name('Midwest').id
            when 'FL'
              Region.find_by_name('Florida').id
            when 'GA', 'AL', 'MS', 'TN', 'SC', 'NC'
              Region.find_by_name('Southeast').id
            when 'VA', 'WV', 'DE', 'MD', 'NJ', 'PA'
              Region.find_by_name('East').id
            when 'BC', 'AB', 'ON', 'NS', 'MB'
              Region.find_by_name('Canada').id
            end
            puts "  region: #{region_id}"   
          end # end each place      
        end # end each response
      end # end if result == 200
    end # end each event
  end # end rake task

  desc "Output the geocode all events via yahoo geocoder"   
  task :yahoo_geocode => :environment do
    api_key=YAHOO_API_KEY

    (Event.find :all).each do |event|
      puts "\nevent: #{event.name}"

      url="http://api.local.yahoo.com/MapsService/V1/geocode?appid=#{api_key}&location=#{CGI.escape(event.location)}"
      xml=open(url).read
      doc=REXML::Document.new(xml)

      doc.root.each_element('//Result') do |result|
	#puts result
        puts "Result Precision: " << result.attributes['precision']
        if result.attributes['precision'] != 'address'
          #puts "Warning: " << result.attributes['warning']
          puts "Address: " << result.elements['//Address'].text.to_s
        end
        puts "Latitude: " << result.elements['//Latitude'].text
        puts "Longitude: " << result.elements['//Longitude'].text
            
      end # end each result
    end  # end each event
  end # end task

  desc "Output the geocode all events via geocoder_us geocoder"   
  task :geocoder_us => :environment do
    (Event.find :all).each do |event|
      puts "\nevent: #{event.name}"

      url="http://geocoder.us/service/csv/geocode?address=#{CGI.escape(event.location)}"
      res=open(url).read.chomp
      lat,lng,address,city,state,zip=res.split(',')

      puts "Latitude: #{lat}" 
      puts "Longitude: #{lng}"

    end  # end each event
  end # end task  

  desc "Update the events table via google geocoder"   
  task :google_persist => :environment do
    api_key=GOOGLE_MAPS_KEY # set in environment.rb

    (Event.find :all).each do |event|

      puts "\nevent: #{event.name}"
      puts "Source Address: #{event.location}"

      xml=open("http://maps.google.com/maps/geo?q=#{CGI.escape(event.location)}&output=xml&key=#{api_key}").read
      doc=REXML::Document.new(xml)

      puts "Status: "+doc.elements['//kml/Response/Status/code'].text

      if doc.elements['//kml/Response/Status/code'].text != '200'
        puts "Unable to parse Google response for #{event.name}"
      else
        lng,lat=doc.root.elements['//coordinates'].text.split(',')
        event.lat=lat.to_f
        event.lng=lng.to_f
        event.save
      end # end if result == 200
    end # end each event
  end # end rake task
  
  desc "Update the ungeocoded events table via google geocoder"   
  task :google_uncoded_persist => :environment do
    api_key=GOOGLE_MAPS_KEY # set in environment.rb

    (Event.find :all, :conditions => "lat is NULL or lng is NULL").each do |event|

      puts "\nevent: #{event.name}"
      puts "Source Address: #{event.location}"

      #puts "http://maps.google.com/maps/geo?q=#{CGI.escape(event.location)}&output=xml&key=#{api_key}"

      xml=open("http://maps.google.com/maps/geo?q=#{CGI.escape(event.location)}&output=xml&key=#{api_key}").read
      #puts xml
      doc=REXML::Document.new(xml)

      puts "Status: "+doc.elements['//kml/Response/Status/code'].text

      if doc.elements['//kml/Response/Status/code'].text != '200'
        puts "Unable to parse Google response for #{event.name}"
      else
        lng,lat=doc.root.elements['//coordinates'].text.split(',')
        event.lat=lat.to_f
        event.lng=lng.to_f
        state=doc.root.elements['//AddressDetails/Country/AdministrativeArea/AdministrativeAreaName/'].text
        # determine region via event.state
        region_id = case state
        when 'CA'
          if event.lat > 36.3219
            Region.find_by_name('NorCal').id
          else
            Region.find_by_name('SoCal').id              
          end
        when 'NV'
          if event.lng < -118.6846
            Region.find_by_name('NorCal').id
          else
            Region.find_by_name('Mountain').id
          end              
        when 'ME', 'NH', 'VT', 'NY', 'CT', 'RI', 'MA'
          Region.find_by_name('Northeast').id
        when 'WA', 'OR', 'ID'
          Region.find_by_name('Northwest').id
        when 'UT', 'CO', 'WY', 'MT'
          Region.find_by_name('Mountain').id
        when 'AZ', 'NM'
          Region.find_by_name('Southwest').id
        when 'TX', 'OK', 'AR', 'LA'
          Region.find_by_name('South Central').id
        when 'KS', 'MO', 'NE', 'IA'
          Region.find_by_name('Central').id
        when 'SD', 'ND', 'MN'
          Region.find_by_name('North Central').id
        when 'WI', 'IL', 'IN', 'OH', 'MI', 'KY'
          Region.find_by_name('Midwest').id
        when 'FL'
          Region.find_by_name('Florida').id
        when 'GA', 'AL', 'MS', 'TN', 'SC', 'NC'
          Region.find_by_name('Southeast').id
        when 'VA', 'WV', 'DE', 'MD', 'NJ', 'PA'
          Region.find_by_name('East').id
        when 'BC', 'AB', 'ON', 'NS', 'MB'
          Region.find_by_name('Canada').id
        end
        event.region_id = region_id
        event.save
        puts event.name
      end # end if result == 200
    end # end each event
  end # end rake task
  
  desc "Update the ungeocoded events table via best choice geocoder"   
  task :geocode_best_post => :environment do
    include GeoKit::Geocoders
    (Event.find :all, :conditions => "lat is NULL or lng is NULL").each do |event|
      res=MultiGeocoder.geocode(event.location)
      if res.success 
        puts "\nevent: #{event.name}"
        puts "Source Address: #{event.location}"
        puts "Result Address: #{res.street_address}"
        puts "  Latitude: #{res.lat}"
        puts "  Longitude: #{res.lng}"
        puts "  State: #{res.state}"
        puts "  Provider: #{res.provider}"
        event.lat = res.lat
        event.lng = res.lng
        event.state = res.state
        event.region_id = case res.state
        when 'CA'
          if event.lat > 36.3219
            Region.find_by_name('NorCal').id
          else
            Region.find_by_name('SoCal').id
          end
        when 'NV'
          if event.lng < -118.6846
            Region.find_by_name('NorCal').id
          else
            Region.find_by_name('Mountain').id
          end              
        when 'ME', 'NH', 'VT', 'NY', 'CT', 'RI', 'MA'
          Region.find_by_name('Northeast').id
        when 'WA', 'OR', 'ID'
          Region.find_by_name('Northwest').id
        when 'UT', 'CO'
          Region.find_by_name('Mountain').id
        when 'AZ', 'NM'
          Region.find_by_name('Southwest').id
        when 'TX', 'LA'
          Region.find_by_name('Texas').id
        when 'OK', 'AR'
          Region.find_by_name('South Central').id
        when 'KS', 'MO', 'NE', 'IA'
          Region.find_by_name('Central').id
        when 'SD', 'ND', 'MN'
          Region.find_by_name('North Central').id
        when 'WI', 'IL', 'IN', 'OH', 'MI', 'KY'
          Region.find_by_name('Midwest').id
        when 'FL'
          Region.find_by_name('Florida').id
        when 'GA', 'AL', 'MS', 'TN', 'SC', 'NC'
          Region.find_by_name('Southeast').id
        when 'VA', 'WV', 'DE', 'MD', 'NJ', 'PA'
          Region.find_by_name('East').id
        when 'BC', 'AB', 'ON', 'NS', 'MB'
          Region.find_by_name('Canada').id
        when 'WY', 'MT'
          Region.find_by_Name('Mountain North').id
        end # end case
        puts "   Region ID: #{event.region_id}"
        event.save
      end # end if success
    end # event loop
  end # end rake task    
  
end # end namespace