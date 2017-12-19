$:.unshift File.expand_path("../lib",__FILE__)

require 'zscheduler'
require 'rake'

Gem::Specification.new do |s|
  s.name                  = "zscheduler"
  s.version               = Zscheduler::VERSION
  s.platform              = Gem::Platform::RUBY
  s.summary               = "minimalistic scheduler on top of event-machine"
  s.description           = "minimalistic scheduler on top of event-machine "
  s.author                = "Eran Barak Levi"
  s.email                 = "wtf@wtf.com"
  s.homepage              = 'http://github.com/eranb/zscheduler'
  s.required_ruby_version = '>= 1.8.5'
  s.rubyforge_project     = "zscheduler"
  s.license               = 'LGPL-3.0'
  s.files                 = FileList["{lib}/**/*"].to_a.<< "LICENSE"
  s.require_path          = "lib"
  s.require_paths         = ["lib"]

  s.add_dependency 'eventmachine'
end
