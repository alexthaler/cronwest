require 'sinatra'
require 'mongo'
require 'json'
require 'time'
require_relative 'cronwestpoller'

include Mongo

class Cronwest < Sinatra::Base

    configure do 
        puts "configurating!"
        $client = MongoClient.new('localhost', 27017)
        $db = $client['sample-db']
        $jobs = $db['jobs']
        $analytics = $db['analytics']

        set :public_folder, 'public'

        CronWestPoller.new.spawn_poller($jobs, 5)
    end

    get '/' do
        send_file File.join(settings.public_folder, 'index.html')
    end

    get '/job/:job_id' do
        logger.info "in jobid finding job #{params[:job_id]}"
        puts $jobs.find({"jobId" => params[:job_id].to_i}).to_a
    end

    post '/job' do 
        json_body = request.body.read
        new_job = JSON.parse(json_body)
        verify_and_setup_job(new_job)

        if Time.parse(new_job['startTime']) > Time.now.utc then
            puts "Time #{new_job['startTime']} is later than now so it will be saved"
            inserted_job = $jobs.insert(new_job)    
        else 
            puts "Time #{new_job['startTime']} is before now and cannot be saved"
            return 500
        end    

        return new_job['jobId']
    end

    def verify_and_setup_job(new_job)

        new_job['jobId'] = SecureRandom.uuid

        raise ArgumentError, 'firstName, lastName and confirmationNumber must be supplied for new jobs' unless 
            new_job.has_key?('firstName') and new_job.has_key?('lastName') and new_job.has_key?('confirmationNumber')
    end

end
