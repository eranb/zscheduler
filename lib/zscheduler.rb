require 'eventmachine'
require 'zscheduler/version'

module Zscheduler
  class << self

    def every(frequency,options = {}, &block)
      block_given? or raise ArgumentError, "no block was given..."

      reactor_running? or start_reactor

      add_shutdown_hook &block if options[:on_shutdown]
      block.call if options[:immediately]

      timers.push EM::PeriodicTimer.new(Integer frequency) do
        options[:on_thread] ? Thread.new(&block) : block.call
      end

      timers.last
    end

    def stop
      timers.each(&:cancel)
      shutdown_hooks.each(&:call)
      wrapper and EM.stop
    end

    alias_method :showdown, :stop

    def add_shutdown_hook(&block)
      shutdown_hooks.push block
    end

    def join
      (wrapper or EM.reactor_thread).join
    end

    private

    def start_reactor
      @wrapper = Thread.new { EventMachine.run }
      wrapper.abort_on_exception = true
      Thread.pass until reactor_running?
    end

    def reactor_running?
      EventMachine.reactor_running?
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

