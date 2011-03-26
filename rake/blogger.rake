namespace :blogger do
  desc "post weekend update to blogger"
  task :weekend_update  => :environment do
    require 'blogger'
    
    # preferences for blogger login
    username = 'sample@gmail.com' # change this to your username
    password = 'xxx129304xxxx' # change this to your password
    blog_id = '123456' # change this to your blogid

    # my entry preferences
    days_ahead = 5 # how many days of events ?
    blog_entry = "For those of you making your weekend plans, 
                  here is quick rundown of this weekend\'s MTB racing schedule 
                  for NorCal:\n\n"
    
    # google static map preferences 
    base_url = "http://maps.google.com/maps/api/staticmap?"
    map_params = ["size=400x400", "maptype=roadmap", "sensor=false"]

    # find all events in the mtbcalendar.com db for this weekend
    @events = Event.active.find_tagged_with(
        "norcal", 
        :conditions => ["start_date >= CURRENT_DATE AND start_date < ?", 
                        days_ahead.days.from_now], 
        :order => "start_date asc")

    # loop through events adding place markers to the google static map URL
    x = 0
    @events.each do |marker|
      x += 1
      map_params << "markers=color:blue|label:#{x}|#{marker.lat},#{marker.lng}"
      blog_entry += "#{x}. [#{marker.name}](http://mtbcalendar.com/events/#{marker.id})
                    (#{marker.start_date.to_s(:compact)})\n"
    end # marker loop

    # add the google static map to post body
    map_pic_url = base_url + map_params.join('&')
    blog_entry += "\n![NorCal MTB Race Event Map](" + map_pic_url + ")"

    # create title for the post
    blog_title = "NorCal MTB Racing This Weekend: 
                  #{Date.today.to_s(:short)} - 
                  #{days_ahead.days.from_now.to_date.to_s(:short)}, 
                  #{Date.today.year}"

    # login into blogger and post this draft
    account     = Blogger::Account.new(username,password)
    new_post    = Blogger::Post.new(:title      => blog_title, 
                                    :content    => blog_entry,
                                    :formatter  => :rdiscount,
                                    :draft      => true)
    account.post(blog_id,new_post)

  end # task    
end # namespace