require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "ConnectionTest" do
  context Istat::Frames::ConnectionTestRequest do
    it "should be possible to generate a correct request" do
      frame = Istat::Frames::ConnectionTestRequest.new
      frame.to_s.should == "<?xml version='1.0' encoding='UTF-8'?><isr><conntest/></isr>"
    end
  end
  
  context Istat::Frames::ConnectionTestResponse do
    it "should be possible to parse a response" do
      xml = %{<?xml version="1.0" encoding="UTF-8"?><isr></isr>}
      frame = Istat::Frames::ConnectionTestResponse.new(xml)
      frame.success?.should be_true
    end
  end
end
