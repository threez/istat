require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Authentication" do
  context Istat::Frames::AuthenticationRequest do
    it "should be possible to generate a correct password frame" do
      frame = Istat::Frames::AuthenticationRequest.new("test")
      frame.to_s.should == "test"
    end
  end
  
  context Istat::Frames::AuthenticationResponse do
    it "should be possible to parse the authentication response" do
      xml = %{<?xml version="1.0" encoding="UTF-8"?><isr ready="1"></isr>}
      frame = Istat::Frames::AuthenticationResponse.new(xml)
      frame.ready?.should be_true
      frame.rejected?.should be_false
      xml = %{<?xml version="1.0" encoding="UTF-8"?><isr athrej="1"></isr>}
      frame = Istat::Frames::AuthenticationResponse.new(xml)
      frame.rejected?.should be_true
      frame.ready?.should be_false
    end
  end
end
