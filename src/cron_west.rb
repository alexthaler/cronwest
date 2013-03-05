require 'sinatra'
require 'mongo'
require 'json'
require 'time'
require 'logger'
require_relative 'cronwest_poller'
require_relative 'cronwest_data_manager'

include Mongo

class CronWest < Sinatra::Base

    configure do
        if ENV['MONGOHQ_URL']
            db = URI.parse(ENV['MONGOHQ_URL'])
            db_name = db.path.gsub(/^\//, '')
            @db_connection = Mongo::Connection.new(db.host, db.port).db(db_name)
            @db_connection.authenticate(db.user, db.password) unless (db.user.nil? || db.password.nil?)
            $client = @db_connection
        else
            $client = MongoClient.new('localhost', 27017)
        end

        $db = $client['cronwest-db']
        $data_manager = CronWestDataManager.new($db)

        set :public_folder, 'public'
        enable :logging

        $poller = CronWestPoller.new.spawn_poller($data_manager, 5)
    end

    configure :production do
        set :clean_trace, true
        Dir.mkdir('logs') unless File.exist?('logs')

        $logger = Logger.new('logs/common.log','weekly')
        $logger.level = Logger::INFO

        # Spit stdout and stderr to a file during production
        # in case something goes wrong
        $stdout.reopen("logs/output.log", "w")
        $stdout.sync = true
        $stderr.reopen($stdout)
    end

    configure :development do
        $logger = Logger.new(STDOUT)
    end

    get '/' do
        send_file File.join(settings.public_folder, 'index.html')
    end

    get '/job/:job_id' do
        $logger.info "in jobid finding job #{params[:job_id]}"
        $data_manager.find_jobs_by_id(params[:job_id].to_i).to_a
    end

    post '/job' do 
        json_body = request.body.read
        new_job = JSON.parse(json_body)
        verify_and_setup_job(new_job)

        if Time.parse(new_job['startTime']) > Time.now.utc then
            $logger.info "Time #{new_job['startTime']} is later than now so it will be saved"
            created_job = $data_manager.create_job(new_job)
        else 
            $logger.info "Time #{new_job['startTime']} is before now and cannot be saved"
            return 500
        end    

        new_job['jobId']
    end

    def verify_and_setup_job(new_job)

        new_job['jobId'] = SecureRandom.uuid

        raise ArgumentError, 'firstName, lastName and confirmationNumber must be supplied for new jobs' unless 
            new_job.has_key?('firstName') and new_job.has_key?('lastName') and new_job.has_key?('confirmationNumber')
    end

end
