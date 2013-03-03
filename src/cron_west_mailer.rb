require 'gmail'

class CronWestMailer

    def send_mail(client_email, result)
        puts "sending email"

        email_props = YAML.load_file('src/yml/emailprops.yml')

        puts "trying to send email with account #{email_props['email_account']}"
        sending_email = email_props['email_account']
        sending_email_password = email_props['email_password']

        gmail = Gmail.new(sending_email, sending_email_password)

        email = gmail.generate_message do
          to client_email
          from sending_email
          subject "CronWest Alert"
          body result
        end
        email.deliver!

        gmail.logout

    end

end