require 'erb'

module Glitter
  module Release
    class Base
      attr_reader :channel, :version

      # Initialize a release and yield the block for configuration.
      def initialize(channel, version, &block)
        @channel, @version = channel, version
        block.call self if block_given?
        self
      end

      # Push assets up to the S3 bucket path `/:channel/:version/*`.
      def push
        # raise ExistingReleaseError.new("Existing build at #{asset_object.url.inspect}. Increment the version and push again.") if asset_object.exists?
        objects.each(&:save)
        self
      end

      # Promote the release as the head releae. This copies the contents of the release to `/:channel/*`.
      def head
        objects.map do |object|
          channel, _, file_name = self.class.object_segments(object.key)
          object.copy key: File.join(channel, file_name)
        end.each(&:save)
      end

      # Registry of assets that are S3 objects. The key is `/:channel/:version/:object-key`. The hash returns an S3 object.
      def assets
        @assets ||= Hash.new { |h,k| h[k] = channel.server.bucket.objects.build object_key(k) } # /win-dev/1.1/appcast.xml
      end

      # A short-cut for getting at only the S3 objects.
      def objects
        assets.values
      end

    private

      # Build a key that we'll use to store these objects into S3.
      def object_key(*segments)
        File.join(channel.name, version, segments)
      end

      # Break apart an S3 bucket key by /:channel/:version/:object-key
      def self.object_segments(key)
        if match = key.match(/\/?(.+)\/(.+)\/(.+)/)
          match.captures
        end
      end
    end

    # A release consists of a binary asset, notes, a monotonically increasing version number, and 
    # lives inside of a channel.
    class Sparkle < Base
      attr_accessor :notes, :asset

      def push
        # Get all of our assets in order that were using for sparkle
        assets['appcast.xml'].content = appcast_xml
        assets['release_notes.html'].content = notes_html
        assets[File.basename(asset.path)].content = asset
        # And when that's all squared away, push it up to S3.
        super
      end

      # TODO - Generate HTML for release notes.
      def notes_html
        "<html>#{notes}</html>"
      end

      # TODO - Generate appcast.xml file.
      def appcast_xml
        "<xml>#{notes}</xml>"
      end
    end

  end
end