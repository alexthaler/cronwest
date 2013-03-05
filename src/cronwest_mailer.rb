require 'gmail'

class CronwestMailer

    def send_mail(client_email, result)
        puts "sending email"

        email_props = YAML.load_file('config/emailprops.yml')

        puts "trying to send email with account #{email_props['email_account']}"

        if ENV['SEND_GMAIL_ACCOUNT'] and ENV['SEND_GMAIL_PASSWORD']
            puts "using gmail env values"
            sending_email = ENV['SEND_GMAIL_ACCOUNT']
            sending_email_password = ENV['SEND_GMAIL_PASSWORD']
        else
            puts "using gmail property values"
            sending_email = email_props['email_account']
            sending_email_password = email_props['email_password']
        end

        gmail = Gmail.new(sending_email, sending_email_password)

        email = gmail.generate_message do
          to client_email
          from "CronWest Alerts"
          subject "CronWest Alert"
          body result
        end
        email.deliver!

        gmail.logout

    end

end