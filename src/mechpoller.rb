require 'time'
require_relative 'mechdriver'


class MechPoller

    def spawn_poller(jobs, timeout)
        Thread.new(jobs, timeout) do |jobs, timeout|
            while true do
                puts "polling"
                jobs.find.each do |row|
                    puts "Job #{row['jobId']} has startTime #{row['startTime']}"
                    if Time.parse(row['startTime']) < Time.now.utc
                        puts "Job #{row['jobId']}s startTime has passed and is now being triggered"
                        execute_request(row)
                        jobs.remove({:jobId => row['jobId']})
                    end
                end
                sleep(timeout)
            end
        end
    end

    def execute_request(job)
        MechDriver.new.fire_request({:firstName => job['firstName'], :lastName => job['lastName'],
                                     :confirmationNumber => job['confirmationNumber']})
    end

end