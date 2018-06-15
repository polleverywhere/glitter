require 'spec_helper'
require 'rexml/document'

describe Glitter do
  let(:server) do
    Glitter::Server.new
  end

  # Note that running this spec *will* upload a single file to your S3 bucket
  it "should release to channel" do
    Glitter::Release::Sparkle.new server.channel('test-channel'), "1.1.2-#{rand}" do |r|
      r.executable = File.open(__FILE__)
      r.notes = %[Did you know that its #{Time.now}? Wait, you can only answer yes to that question.]
      r.minimum_system_version = "10.10"
    end.push.head
  end

  it "AWS path segments are parsed correctly for an item at top level of version folder" do
    channel, version, key = Glitter::Release.object_segments("/channel/version/some-item")
    expect(channel).to eq("channel")
    expect(version).to eq("version")
    expect(key).to eq("some-item")
  end

  it "AWS path segments are parsed correctly for an item in subfolder of version folder" do
    channel, version, key = Glitter::Release.object_segments("/channel/version/some-dir/some-item")
    expect(channel).to eq("channel")
    expect(version).to eq("version")
    expect(key).to eq("some-dir/some-item")
  end
end
