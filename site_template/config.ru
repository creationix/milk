require 'milk'

# use Lock
if %w{rackup thin}.member?($0.rpartition('/').last)
  puts "Running in development mode"
  use ContentLength
  use Reloader
  run Cascade.new([
    File.new('public'),
    Milk::Application.new
  ])
else
  # When using passenger, require secure cookies and don't bother with static files
  run Milk::Application.new(true)
end

