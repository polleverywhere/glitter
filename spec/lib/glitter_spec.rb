require 'spec_helper'
require 'rexml/document'

describe Glitter do

  # # Note that uncommenting and running this spec *will* upload a single file to your S3 bucket
  # it "should release to channel" do
  #   Glitter::Release::Sparkle.new Glitter::Server.new.channel('test-channel'), "1.1.2-#{rand}" do |r|
  #     r.executable = File.open(__FILE__)
  #     r.notes = %[Did you know that its #{Time.now}? Wait, you can only answer yes to that question.]
  #     r.minimum_system_version = "10.10"
  #   end.push.head
  # end

  context "when working with appcast filenames" do
    let(:server) { double("Server") }
    let(:bucket) { double("Bucket") }
    let(:objects) { double("Objects") }
    let(:s3_object) { double("S3Object") }
    let(:channel) { Glitter::Channel.new("test", server) }

    before do
      allow(server).to receive(:bucket).and_return(bucket)
      allow(bucket).to receive(:objects).and_return(objects)
      allow(objects).to receive(:build).and_return(s3_object)
      allow(s3_object).to receive(:content=)
      allow(s3_object).to receive(:content_type=)
      allow(s3_object).to receive(:key).and_return("test/1.0/appcast.xml")
      allow(s3_object).to receive(:url).and_return("https://example.com/test/1.0/appcast.xml")
      allow_any_instance_of(Glitter::Release::Sparkle).to receive(:render_template).and_return("<xml></xml>")
    end

    it "should use default appcast filename when not specified" do
      release = Glitter::Release::Sparkle.new(channel, "1.0")
      expect(release.instance_variable_get(:@appcast_filename)).to eq("appcast.xml")

      asset = release.send(:appcast_asset)
      expect(asset).to eq(s3_object)
    end

    it "should allow custom appcast filename" do
      release = Glitter::Release::Sparkle.new(channel, "1.0") do |r|
        r.appcast_filename = "custom-appcast.xml"
      end

      expect(release.instance_variable_get(:@appcast_filename)).to eq("custom-appcast.xml")

      asset = release.send(:appcast_asset)
      expect(asset).to eq(s3_object)
    end
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
