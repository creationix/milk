require 'bootstrap'

if %w{rackup thin}.member?($0.rpartition('/').last)
  puts "Running in development mode"
  use ContentLength
  use Reloader
  run Cascade.new([
    File.new('public'),
    Milk::Application.new
  ])
else
  run Milk::Application.new(true)
end

