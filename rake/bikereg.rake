namespace :nugget do
  desc "Check for new nuggets from bikereg.com"
  task :bikereg  => :environment do

  require 'open-uri'
  require 'simple-rss'
  require 'hpricot'
  require 'net/http'
  require 'xmlsimple'

  $verbose = false
  rss_url = "http://www.bikereg.com/events/rssfeed.asp?et=3&rg=&ns=&ne=50"
  rss_user_agent = "Google"

  def fetchRSS(url, user_agent)
    # this grabs the rss feed and returns rss_items array
    begin
      puts "fetching #{url} ..." if $verbose
      rss_items = SimpleRSS.parse open(url, "User-Agent" => user_agent)
    rescue
      puts "Cannot grab feed: #{url}"
      return nil
    end
  end

  def inDB?(key)
    Nugget.find_by_source(key)
  end

  def parseBikeReg(item)
    details = item.title.split(' - ')
    unless details.size > 3
      # more than three details means there's a parse problem
      reg_url = item.link
      name = details[0]
      funkydate = details[1]
      location = details[2]
      if funkydate.to_date > Date.today
        # grab home url from reg page
        url = scrapeHomeUrlFromBikeReg(reg_url)
        unless url.nil?
          puts "#{funkydate.to_date}: #{name} (#{location})" if $verbose
          Nugget.new(:name => name, :location => location,
            :url => url, :start_date => funkydate.to_date, :description => "", 
            :end_date => funkydate.to_date, :source => reg_url, :reg_url => reg_url, 
            :published => false)
        end
      end
    else
      puts "bad details in #{item.link}: #{details.size}" if $verbose
    end
  end

  def scrapeHomeUrlFromBikeReg(url)
    begin
      doc = Hpricot(open(url))
      element = doc.search("div#divRegNav>a:nth-of-type(1)")
      element[0].attributes['href']
    rescue
      return nil
    end
  end

    # Main
    # loop thru rss_urls, parse them, then stuff into nugget db
    puts "entering verbose mode" if $verbose
    events = Array.new
    this_feed = rss_url
    # loop through events to parse them and create event array
    puts "examing #{this_feed} ..." if $verbose
    rss_items = fetchRSS(this_feed, rss_user_agent)
    for item in rss_items.items
      if inDB?(item.link)
        puts "exists: #{item.link}" if $verbose
      else
        events << parseBikeReg(item)
      end
    end

    # loop through parsed events and add to nugget database
    unless events.nil?
      puts "commiting to DB ..." if $verbose
      events.compact.each do |e|
        if e.save
          puts "DB => #{e.start_date}: #{e.name} (#{e.location}) #{e.source}"  #if $verbose
        else
          puts "DB FAILED #{e.name} (#{e.source})"
          e.errors.each_full{|msg| puts msg }
        end
      end
    end
  end # task

end # namespace