# README

This is a simple demo of a single job running on multiple workers, due to the way DelayedJob interacts with the `Timeout`.

## How to run this

Enqueue a single `TimeoutJob`:

```sh
diogo@diogo-MD6T ~/w/s/delayed_job_timeout_example (main)> bundle exec rails c                                                │
Running via Spring preloader in process 18869                                                                                 │
Loading development environment (Rails 6.1.7)                                                                                 │
irb(main):001:0> TimeoutJob.perform_later
=>                                                                                                                            │
#<TimeoutJob:0x00000001133eaf80                                                                                               │
 @arguments=[],                                                                                                               │
 @exception_executions={},                                                                                                    │
 @executions=0,                                                                                                               │
 @job_id="0ca31c17-c030-45e4-b8ce-01734a3f399b",                                                                              │
 @priority=nil,                                                                                                               │
 @provider_job_id=4,                                                                                                          │
 @queue_name="default",                                                                                                       │
 @timezone="UTC">                                                                                                             │
irb(main):002:0>
```

And run 2 workers (e.g. `bundle exec rake jobs:work` twice).


## Explanation

Given the following configuration:

```rb
Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 10
Delayed::Worker.delay_jobs = true
```

And the following job:

```rb
class TimeoutJob < ApplicationJob
  queue_as :default

  def perform(*args)
    100.times do
      puts "[#{Process.pid}] Sleeping 10s..."
      sleep(10)
      puts "[#{Process.pid}] Slept 10s"
    rescue StandardError => e
      puts "[#{Process.pid}] Caught an error #{e.class}: #{e.message}"
    end
  end
end
```

One would expect that after 10s (the `max_run_time` set), for the first process that picked up the job to timeout
and the job to be marked as failed.

What actually happens:

1. The first worker swallows the timeout error and keeps working
2. The second worker picks up / locks the same job, because in theory the job has timed out (i.e. `max_run_time` was achieved
since the job was initially picked up)

If you launch a 3rd worker, you'll see the same pattern.
