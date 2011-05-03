require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Istat::Client do
  before(:each) do
    @client = Istat::Client.new(SERVER.host, SERVER.port, SERVER.password,
                                LOGGER)
  end
  
  it "should be possible to connect and disconnect to/from an istat server" do
    @client.connect!.should be_true
    @client.close!.should be_true
  end
  
  it "should be possible to test a connection" do
    @client.connect!.should be_true
    @client.online?.should be_true
    @client.close!.should be_true
  end

  it "should be possible to register the host" do
    @client.connect!.should be_true
    @client.register!
    @client.close!.should be_true
  end
  
  it "should be possible to authorize correctly" do
    @client.connect!.should be_true
    @client.register!
    @client.authenticate!
    @client.close!.should be_true
  end
  
  it "should be possible to use Client#start to start, authenticate, register and stop" do
    @client.start do |session|
      session.connection_frame.uptime.should > 0
    end
  end
  
  it "should be possible to request host data" do
    @client.start do |session|
      response = session.fetch
      response.network?.should be_true
      response.cpu?.should be_true
      response.memory?.should be_true
      response.load?.should be_true
      response.uptime?.should be_true
      response.disks?.should be_true
    end
  end
  
  it "if ask data for two different time spans i should get different result set sizes" do
    @client.start do |session|
      response = session.fetch_all
      result = response.cpu.size
      response = session.fetch
      response.cpu.size.should < result
    end
  end
end
