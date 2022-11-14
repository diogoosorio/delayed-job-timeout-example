Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 10
Delayed::Worker.delay_jobs = true

Delayed::Worker.logger = Logger.new(STDOUT)
ActiveRecord::Base.logger = Logger.new(STDOUT)
