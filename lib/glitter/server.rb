require 's3'
require 'uri'

# Glitter servers currently work with Amazon S3 buckets. They contain multiple channels which
# contain multiple releases of software.
module Glitter
  class Server
    attr_reader :access_key_id, :secret_access_key, :bucket_name

    def initialize(access_key_id = ENV['AWS_ACCESS_KEY_ID'], secret_access_key = ENV['AWS_SECRET_ACCESS_KEY'], bucket_name = ENV['AWS_BUCKET_NAME'])
      @access_key_id, @secret_access_key, @bucket_name = access_key_id, secret_access_key, bucket_name
    end

    def channel(name)
      channels[name]
    end

    def bucket
      @bucket ||= s3.buckets.find bucket_name
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
      @s3 ||= ::S3::Service.new(:access_key_id => access_key_id, :secret_access_key => secret_access_key, :use_ssl => true)
    end
  end
end