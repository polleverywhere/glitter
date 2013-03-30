require 'glitter/version'

module Glitter
  ExistingReleaseError = Class.new(RuntimeError)
  
  # Relative paths for glitter. Mostly our templating engines use this.
  def self.path(*segments)
    File.join File.expand_path('../glitter', __FILE__), *segments
  end

  autoload :Configurable, Glitter.path('configurable')
  autoload :Channel,      Glitter.path('channel')
  autoload :Release,      Glitter.path('release')
  autoload :Server,       Glitter.path('server')
  autoload :CLI,          Glitter.path('cli')
end
