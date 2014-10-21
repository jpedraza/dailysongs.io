listen           (ENV["PORT"] || 3000).to_i
timeout          15
preload_app      true
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)

before_fork do |server, worker|
  Signal.trap "TERM" do
    puts "Unicorn master intercepting TERM and sending myself QUIT instead."

    Process.kill("QUIT", Process.pid)
  end

  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end
end

after_fork do |server, worker|
  Signal.trap "TERM" do
    puts "Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT."
  end

  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end
