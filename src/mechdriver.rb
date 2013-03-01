require 'rubygems'
require 'mechanize'

class MechDriver

    def fire_request() 
        a = Mechanize.new { |agent|
          agent.user_agent_alias = 'Mac Safari'
        }

        a.get('http://www.southwest.com/flight/retrieveCheckinDoc.html?forceNewSession=yes') do |page|

          checkin_result = page.form_with(:name => 'retrieveItinerary') do |checkin|
            checkin.confirmationNumber = 'FOOAWESOME'
            checkin.firstName = 'Thomas'
            checkin.lastName = 'Awesome'
          end.submit

          return checkin_result.search('#errors li').to_s.gsub(/<\/?[^>]*>/, "")
        end
    end

end