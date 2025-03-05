require 'erb'
require 'logger'

module Glitter
  module Release
    # Break apart an S3 bucket key by /:channel/:version/:object-key
    def self.object_segments(key)
      if match = key.match(/\/?(.+?)\/(.+?)\/(.+)/)
        match.captures
      end
    end

    class Base
      attr_reader :channel, :version, :logger

      # Initialize a release and yield the block for configuration.
      def initialize(channel, version, logger = Logger.new($stdout), &block)
        @channel, @version, @logger = channel, version, logger
        @appcast_filename = 'appcast.xml'
        block.call self if block_given?
        self
      end

      # Push assets up to the S3 bucket path `/:channel/:version/*`.
      def push(opts={})
        if !opts[:force] and version_exists?
          raise ExistingReleaseError.new("Existing build at version #{version}. Increment the version and push again.")
        end

        logger.warn "Forced push" if opts[:force]

        logger.info "Pushing version #{version} to #{channel.name}"
        assets.each do |key, object|
          logger.info " PUT #{key} to #{object.url}"
          object.save
        end
        logger.info "Version #{version} to #{channel.name} pushed!"
        self
      end

      # Promote the release as the head releae. This copies the contents of the release to `/:channel/*`.
      def head
        logger.info "Promoting version #{version} to HEAD"
        assets.map do |_, object|
          channel, _, key = Release.object_segments(object.key)
          object = object.copy :key => File.join(channel, key)
          logger.info " Copying #{key} to #{object.url}"
          object.save
        end
        logger.info "Version #{version} promoted to HEAD!"
      end

      # Registry of assets that are S3 objects. The key is `/:channel/:version/:object-key`. The hash returns an S3 object.
      def assets
        @assets ||= Hash.new { |h,k| h[k] = channel.server.bucket.objects.build object_key(k) } # /win-dev/1.1/appcast.xml
      end

    private
      # Figure out if the version already exists on the remote bucket.
      def version_exists?
        channel.versions.include? version
      end

      # Build a key that we'll use to store these objects into S3.
      def object_key(*segments)
        File.join(channel.name, version, segments)
      end
    end

    # A release consists of a binary asset, notes, a monotonically increasing version number, and
    # lives inside of a channel.
    class Sparkle < Base
      attr_accessor :notes, :executable, :filename, :appcast_filename
      attr_writer   :published_at, :bundle_version, :minimum_system_version

      # Yeah, lets publish this shiz NOW.
      def published_at
        @published_at ||= Time.now
      end

      # Generate assets and push
      def push(*args)
        notes_asset
        appcast_asset
        executable_asset
        super(*args)
      end

      def bundle_version
        @bundle_version || @version
      end

      def minimum_version_attribute
        unless @minimum_system_version.nil?
          "<sparkle:minimumSystemVersion>#{@minimum_system_version}</sparkle:minimumSystemVersion>"
        end
      end

    private
      # Generates an HTML file of the release notes.
      def notes_asset
        assets['notes.html'].tap do |a|
          a.content = render_template 'notes.html.erb'
          a.content_type = 'text/html'
        end
      end

      # Generates the XML appcast file needed to publish zie document
      def appcast_asset
        assets[appcast_filename].tap do |a|
          a.content = render_template 'appcast.xml.erb'
          a.content_type = 'application/xml'
        end
      end

      # Package up the installer executable and add to the release.
      def executable_asset
        assets[executable_key].tap do |a|
          a.content = executable
          a.content_type = 'application/octet-stream'
        end
      end

      def executable_key
        File.basename(executable.path)
      end

      def render_template(path)
        ERB.new(File.read(Glitter.path('templates', path))).result(self.send(:binding))
      end
    end

  end
end