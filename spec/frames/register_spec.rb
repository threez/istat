require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Registration" do
  context Istat::Frames::RegisterRequest do
    it "should be possible to generate a correct password frame" do
      frame = Istat::Frames::RegisterRequest.new("macbook.local", "42c4e086890f9e2c1b2b7221b2422136")
      frame.to_s.should == "<?xml version='1.0' encoding='UTF-8'?><isr><h>macbook.local</h><duuid>42c4e086890f9e2c1b2b7221b2422136</duuid></isr>"
    end
  end
  
  context Istat::Frames::RegisterResponse do
    it "should be possible to parse the authentication response" do
      xml = %Q{<?xml version="1.0" encoding="UTF-8"?><isr pl="2" ath="1" ss="6" c="28406490" n="28406489"></isr>}
      frame = Istat::Frames::RegisterResponse.new(xml)
      frame.ss.should == 6
      frame.uptime == 28406489
      frame.next_uptime.should == 28406490
      frame.authorize?.should be_true
      frame.pl.should == 2
    end
  end
end
