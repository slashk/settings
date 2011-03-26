desc "send prowl alert with message"
task :prowl, :message do |t, args|
  # see http://bit.ly/bAsNnT for details
  require 'prowly'

  prowl_message = args[:message]
  prowl_api_key = ""

  unless prowl_message.nil?
    notif = Prowly::Notification.new(
      :apikey => prowl_api_key,
      :application => "mtbcalendar.com",
      :event => "Alert",
      :priority => Prowly::Notification::Priority::MODERATE,
      :description => prowl_message)

    response = Prowly.notify(notif)

    puts response.message if response.status == "error"
  end
end
