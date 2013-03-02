require 'rubygems'
require 'mechanize'

class CronWestDriver

    def fire_request(opts) 
        a = Mechanize.new { |agent|
          agent.user_agent_alias = 'Mac Safari'
        }

        a.get('http://www.southwest.com/flight/retrieveCheckinDoc.html?forceNewSession=yes') do |page|

          checkin_result = page.form_with(:name => 'retrieveItinerary') do |checkin|
            checkin.confirmationNumber = opts[:confirmationNumber]
            checkin.firstName = opts[:firstName]
            checkin.lastName = opts[:lastName]
          end.submit

          return checkin_result.search('#errors li').to_s.gsub(/<\/?[^>]*>/, "")
        end
    end

end