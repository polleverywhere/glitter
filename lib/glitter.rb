require 'glitter/version'

module Glitter
  ExistingReleaseError = Class.new(RuntimeError)

  autoload :Configurable, 'glitter/configurable'
  autoload :Channel,      'glitter/channel'
  autoload :Release,      'glitter/release'
  autoload :Server,       'glitter/server'
  autoload :CLI,          'glitter/cli'
end
