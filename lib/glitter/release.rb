require 'erb'

module Glitter
  # A release consists of a binary asset, notes, a monotonically increasing version number, and 
  # lives inside of a channel.
  class Release
    include Configurable

    attr_configurable :version, :notes, :asset
    attr_reader :channel

    def initialize(channel, &block)
      @channel = channel
      configure(&block) if block_given?
      self
    end

    def objects
      [ asset_object, appcast_object ]
    end

    # Shortcut for pushing a release up to a server.
    def push
      raise ExistingReleaseError.new("Existing build at #{asset_object.url.inspect}. Increment the version and push again.") if asset_object.exists?
      objects.each(&:save)
      self
    end

    # Promote the current releaes as the head releae.
    def head
      objects.map do |object|
        channel, _, file_name = Release.object_segments(object.key)
        object.copy key: File.join(channel, file_name)
      end.each(&:save)
    end

  private
    def appcast_object
      build_object 'appcast.xml', '<xml></xml>'
    end

    def asset_object
      build_object File.basename(asset.path), asset
    end

    def build_object(key, content)
      object = channel.server.bucket.objects.build object_key(key)
      object.content = content
      object
    end

    # Build a key that we'll use to store these objects into S3.
    def object_key(*segments)
      File.join(channel.name, version, segments)
    end

    def self.object_segments(key)
      if match = key.match(/\/?(.+)\/(.+)\/(.+)/)
        match.captures
      end
    end
  end
end