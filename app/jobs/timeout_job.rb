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
