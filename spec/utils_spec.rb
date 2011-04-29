require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Istat::Utils do
  it "should be possible to generate a pseudo uuid" do
    10.times do
      Istat::Utils.uuid.size.should == 32
    end
  end
end
