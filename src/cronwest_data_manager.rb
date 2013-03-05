class DataManager

	CREATED_JOBS_ANALYTICS_NAME = 'created_jobs'
	COMPLETED_JOBS_ANALYTICS_NAME = 'completed_jobs'

	def initialize(db)
		@main_db = db
		@jobs = db['jobs']
		@analytics = db['analytics']
		verify_analytics_state()
	end

	def create_job(job)
		@jobs.insert(job)
		@analytics.update({:name => CREATED_JOBS_ANALYTICS_NAME}, {:$inc => {:count => 1}})
	end

	def complete_job(job)
		@jobs.remove({:jobId =>job[:jobId]})
		@analytics.update({:name => COMPLETED_JOBS_ANALYTICS_NAME}, ${:$inc => {:count => 1}})
	end

	def verify_analytics_state() 
		if @analytics.find({:name => CREATED_JOBS_ANALYTICS_NAME}).to_a.length == 0
			@analytics.insert(:name => CREATED_JOBS_ANALYTICS_NAME, :count => 0)
		end
		if @analytics.find({:name => COMPLETED_JOBS_ANALYTICS_NAME}).to_a.length == 0
			@analytics.insert(:name => COMPLETED_JOBS_ANALYTICS_NAME, :count => 0)
		end
	end


end