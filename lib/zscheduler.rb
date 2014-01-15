require 'eventmachine'
require 'zscheduler/version'

module Zscheduler
  class << self
    # EM::Timer, EM::PeriodicTimer wrapper
    class Timer < Struct.new(:timer)
      # Cancel timer
      def cancel
        self.timer.cancel
      end
    end

    # Start new scheduler
    # @param [Hash] options
    # @option options [True,False] :now (false) execute the block now
    # @option options [True,False] :on_shutdown (false) execute the block on shutdown
    # @option options [True,False] :on_thread (false) execute the block on a separated thread
    # @option options [Time] :start_at (nil) start the scheduler in a given time
    # @option options [Time] :start_in (nil) start the scheduler in a given delay ( seconds )
    # @return [Timer] EventMachine timer wrapper
    # @example
    #   # Simple timer
    #   Zscheduler.every(10) do
    #     puts "Running every 10 seconds"
    #   end
    #
    #   # Run the block and then start the scheduler
    #   Zscheduler.every(10,now: true) do
    #     puts "Running every 10 seconds"
    #   end
    #
    #   # Run the block every 10 seconds and on shutdown
    #   Zscheduler.every(10,on_shutdown: true) do
    #     puts "Running every 10 seconds and on shutdown"
    #   end
    #
    #   # Start the scheduler in a given time
    #   Zscheduler.every(10,start_at: Time.now + 5) do
    #     puts "Will run 5 seconds from now and then for every 10 seconds"
    #   end
    #
    #   Zscheduler.every(10,start_in: 5) do
    #     puts "Will run 5 seconds from now and then for every 10 seconds"
    #   end
    #
    #   # Run the block on a separated thread
    #   Zscheduler.every(10,on_thread: true) do
    #     puts "I'm running on a separated thread"
    #   end
    #
    def every(frequency,options = {}, &block)
      block_given? or raise ArgumentError, "no block was given..."
      start_reactor

      add_shutdown_hook(&block) if options[:on_shutdown]
      block.call if options[:immediately] || options[:now]

      options[:start_in] = (options[:start_at] - Time.now) if options[:start_at]

      action = proc { options[:on_thread] ? Thread.new(&block) : block.call }
      periodic = proc { EM::PeriodicTimer.new(frequency.to_i,&action) }

      obj = Timer.new
      obj.timer = if options[:start_in]
        EM::Timer.new(options[:start_in]) do
          action.call
          obj.timer = periodic.call
        end
      else
        periodic.call
      end

      timers.push obj
      obj
    end

    # Run callback once
    # @param [Time,Integer] seconds
    # @example
    #   Zscheduler.once(Time.now + 10) do
    #     puts "I'm running 10 seconds from now"
    #   end
    #
    #   # Same as above
    #   Zscheduler.once(10) do
    #     puts "I'm running 10 seconds from now"
    #   end
    def once(seconds, &block)
      start_reactor
      seconds = (seconds - Time.now) if seconds.kind_of?(Time)
      timers.push(Timer.new(EM::Timer.new(seconds.to_i,&block))).last
    end

    # Stop the scheduler, cancel all timers and run all the shutdown hooks
    def stop
      timers.each(&:cancel)
      shutdown_hooks.each(&:call)
      wrapper and EM.reactor_running? and EM.stop
    end

    alias_method :shutdown, :stop

    # Add a new shutdown hook
    # @example
    #   Zscheduler.add_shutdown_hook do
    #     puts "someone called to Zscheduler.stop"
    #   end
    #   Zscheduler.stop
    def add_shutdown_hook(&block)
      shutdown_hooks.push block
    end

    # Sleep until Zscheduler stops
    def join
      (wrapper or EM.reactor_thread).join
    end

    private

    def start_reactor
      return if EM.reactor_running?
      @wrapper = Thread.new(&EM.method(:run))
      wrapper.abort_on_exception = true
      Thread.pass until EM.reactor_running?
    end

    def wrapper
      @wrapper
    end

    def timers
      @timers ||= []
    end

    def shutdown_hooks
      @shutdown_hooks ||= []
    end

  end
end

