module Glitter
  # A Channel is where multiple releases are pushed and incremented monotonically. 
  # Sparkle enabled native applications should be pointed at the head of a channel.
  class Channel
    attr_reader :name, :server

    def initialize(name, server)
      @name, @server = name, server
    end

    def release(&block)
      Release.new(self, &block)
    end

    def versions
      server.channel_versions[name]
    end
  end
end