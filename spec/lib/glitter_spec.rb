require 'spec_helper'
require 'rexml/document'

describe Glitter do
  let(:server) do
    Glitter::Server.new
  end

  it "should release to channel" do
    Glitter::Release::Sparkle.new server.channel('test-channel'), "1.1.2-#{rand}" do |r|
      r.executable = File.open(__FILE__)
      r.notes = %[Did you know that its #{Time.now}? Wait, you can only answer yes to that question.]
    end.push.head
  end
end
