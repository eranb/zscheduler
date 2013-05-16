## Zscheduler 
minimalistic scheduler on top of `event-machine`

### Why ?
two reasons, the first is that we don't need to give a fuck if `event-machine`
reactor is running or not, if its already running we can stop/start the scheduler
w/o affecting the actual reactor and the second reason is to add some useful
scheduling methods as mentioned below.

### Why "Zscheduler" ?
because `scheduler` was already taken on `rubygems.org` and also because of [Zee Germans](http://www.urbandictionary.com/define.php?term=Zee%20Germans).

### Installation
via Gemfile

```ruby
gem 'zscheduler'
```

or via terminal
```
gem install zscheduler
```

### Examples

basic stuff

```ruby
require 'zscheduler'

Zscheduler.every 10 do
  puts "I'm running every 10 seconds!"
end

Zscheduler.join
```

shutdown hooks

```ruby
Zscheduler.every 10, on_shutdown: true do
  puts "I'm running every 10 seconds and on shutdown!"
end

Zscheduler.add_showdown_hook do
  puts "I'll run only on shutdown"
end

Zscheduler.showdown # run shutdown hooks and cancel timers
```

run now and every
```ruby
Zscheduler.every 10, immediately: true do
  puts "I'll run immediately and every 10 seconds"
end

Zscheduler.join
```

run it on a thread

```ruby
Zscheduler.every 10, on_thread: true do
  puts "I'm running on a thread every 10 seconds"
end

Zscheduler.join
```
basic duration utils are also included

```ruby
require 'zscheduler'
require 'zscheduler/core_ext/numeric'

Zscheduler.every 34.seconds do
  puts "I'm running every 34 seconds..."
end

Zscheduler.every 17.minutes do
  puts "I'm running every 17 minutes..."
end

Zscheduler.every 4.hours do
  puts "I'm running every 4 hours..."
end

Zscheduler.join
```

### Coexistence with EventMachine
when it's not running
```ruby
require 'zscheduler'

EventMachine.reactor_running? # => false

Zscheduler.every 10 do
  1 + 1 == 2
end

EventMachine.reactor_running? # => true

Zscheduler.shutdown

EventMachine.reactor_running? # => false
```
and when it's already running

```ruby
EventMachine.reactor_running? # => true

require 'zscheduler'

Zscheduler.every 30, on_shutdown: true do
  puts "Blabla"
end

Zscheduler.shutdown 

EventMachine.reactor_running? # => true
```

