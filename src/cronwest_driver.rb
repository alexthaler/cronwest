require 'rubygems'
require 'mechanize'
require_relative 'cronwest_mailer'

class CronWestDriver

    def fire_request(opts)
        puts "attempting to get result from southwest"
        a = Mechanize.new { |agent|
            agent.user_agent_alias = 'Mac Safari'
        }

        a.get('http://www.southwest.com/flight/retrieveCheckinDoc.html?forceNewSession=yes') do |page|

            checkin_result = page.form_with(:name => 'retrieveItinerary') do |checkin|
                checkin.confirmationNumber = opts[:confirmationNumber]
                checkin.firstName = opts[:firstName]
                checkin.lastName = opts[:lastName]
            end.submit

            result = checkin_result.search('#errors li').to_s.gsub(/<\/?[^>]*>/, "")

            puts "got result from SW: #{result}"

            mailer = CronwestMailer.new
            puts "Sending email to #{opts[:clientEmail]}"
            mailer.send_mail(opts[:clientEmail], result)

        end
    end

end