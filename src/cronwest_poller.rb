require 'time'
require_relative 'cronwest_driver'


class CronWestPoller

    def spawn_poller(jobs, timeout)
        Thread.new(jobs, timeout) do |jobs, timeout|
            while true do
                puts "polling"
                jobs.find.each do |row|
                    puts "Job #{row['jobId']} has startTime #{row['startTime']}"
                    if Time.parse(row['startTime']) < Time.now.utc
                        puts "Job #{row['jobId']}s startTime has passed and is now being triggered"
                        if row['clientEmail'] != nil
                            result = execute_request(row)
                        end
                        puts "Job #{row['jobId']} result:"
                        puts result
                        jobs.remove({:jobId => row['jobId']})
                    end
                end
                sleep(timeout)
            end
        end
    end

    def execute_request(job)
        CronWestDriver.new.fire_request({:firstName => job['firstName'], :lastName => job['lastName'],
                                     :confirmationNumber => job['confirmationNumber'],
                                     :clientEmail => job['clientEmail']})
    end

end