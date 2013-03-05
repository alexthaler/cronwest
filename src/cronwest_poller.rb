require 'time'
require_relative 'cronwest_driver'


class CronWestPoller

    def spawn_poller(data_manager, timeout)
        Thread.new(data_manager, timeout) do |data_manager, timeout|
            while true do
                data_manager.find_all_jobs.each do |job|
                    if Time.parse(job['startTime']) < Time.now.utc
                        $logger.info "Job #{job['jobId']}s startTime has passed and is now being triggered"
                        if job['clientEmail'] != nil
                            execute_request(job)
                        end
                        data_manager.complete_job(job)
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