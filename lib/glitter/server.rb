require 's3'
require 'uri'

# Glitter servers currently work with Amazon S3 buckets. They contain multiple channels which
# contain multiple releases of software.
module Glitter
  class Server
    attr_reader :url

    def initialize(url = ENV['GLITTER_URL'])
      @url = URI.parse(url)
    end

    def channel(name)
      channels[name]
    end

    def bucket
      @bucket ||= s3.buckets.find url.path.gsub(/^\//,'') # Strip leading slash from path.
    end

    # Iterate through the objects in S3 and return a hash of channels containing their
    # respective released versions.
    def channel_versions
      bucket.objects.inject Hash.new { |h,k| h[k] = Set.new } do |hash, object|
        channel, version, _ = Release.object_segments(URI(object.url).path)
        hash[channel].add(version) if channel and version
        hash
      end
    end

  private
    def channels
      Hash.new { |h,k| h[k] = Channel.new(k, self) }
    end

    def s3
      @s3 ||= ::S3::Service.new(:access_key_id => url.user, :secret_access_key => url.password, :use_ssl => true)
    end
  end
end