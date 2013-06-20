$LOAD_PATH.unshift 'lib'
require "runner/version"

Gem::Specification.new do |s|
  s.name              = "runner"
  s.version           = Supernova::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Runs commands."
  s.homepage          = "http://github.com/redjazz96/runner"
  s.email             = "redjazz96@gmail.com"
  s.authors           = [ "Jeremy Rodi" ]
  s.has_rdoc          = false

  s.files             = %w( README.md LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("spec/**/*")

  s.description       = <<desc
  Runs a command or two in the shell with arguments that can be
  interpolated with the interpolation syntax.
desc

  s.add_dependency 'promise', '~> 0.3'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'yard'
end
