require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Measurement" do
  context Istat::Frames::MeasurementRequest do
    it "should be possible to generate a correct request" do
      frame = Istat::Frames::MeasurementRequest.new(1)
      frame.to_s.should == "<?xml version='1.0' encoding='UTF-8'?><isr><rid>1</rid><c>-1</c><n>-1</n><m>-1</m><lo>-1</lo><t>-1</t><f>-1</f><u>-1</u><d>-1</d></isr>"
    end
  end
  
  context Istat::Frames::MeasurementResponse do
    before(:each) do
      @frame = Istat::Frames::MeasurementResponse.new(%Q{
        <?xml version="1.0" encoding="UTF-8"?>
        <isr ds="0" ts="0" fs="0" rid="1">
          <CPU>
            <c id="28388970" u="0" s="0" n="0"></c>
            <c id="28388971" u="0" s="0" n="0"></c>
            <c id="28388972" u="0" s="0" n="0"></c>
            <c id="28388973" u="0" s="0" n="0"></c>
          </CPU>
          <NET if="1">
            <n id="28388970" d="4177773" u="232278672" t="1304082088"></n>
            <n id="28388971" d="4177773" u="232278672" t="1304082089"></n>
            <n id="28388972" d="4177773" u="232278672" t="1304082090"></n>
            <n id="28388973" d="4177773" u="232278672" t="1304082091"></n>
          </NET>
          <MEM w="25938" a="27620" i="11664" f="7983" t="73207" su="3" st="36861" pi="0" po="0"></MEM>
          <LOAD one="0" fv="0" ff="0"></LOAD>
          <UPT u="28388036"></UPT>
          <DISKS>
            <d n="/" uuid="/dev/vzfs" f="9226" p="39.931"></d>
          </DISKS>
          <TEMPS>
            <t i="5" t="64"></t>
            <t i="4" t="30"></t>
            <t i="0" t="30"></t>
            <t i="2" t="29"></t>
            <t i="6" t="61"></t>
            <t i="1" t="52"></t>
            <t i="3" t="50"></t>
          </TEMPS>
          <FANS>
            <f i="0" s="1999"></f>
          </FANS>
        </isr>
      })
    end
    
    it "should be possible to parse the isr header" do
      @frame.rid.should == 1
      @frame.sid_disk.should == 0
      @frame.sid_temp.should == 0
      @frame.sid_fans.should == 0
    end
    
    it "should be possible to parse the cpus" do
      @frame.cpu?.should be_true
      @frame.cpu.should == [
        { :id => 28388970, :user => 0, :system => 0, :nice => 0 },
        { :id => 28388971, :user => 0, :system => 0, :nice => 0 },
        { :id => 28388972, :user => 0, :system => 0, :nice => 0 },
        { :id => 28388973, :user => 0, :system => 0, :nice => 0 }
      ]
    end

    it "should be possible to parse the network" do
      @frame.network?.should be_true
      @frame.network.should == {
        1 => [
          { :id => 28388970, :d => 4177773, :u => 232278672, :t => 1304082088 },
          { :id => 28388971, :d => 4177773, :u => 232278672, :t => 1304082089 },
          { :id => 28388972, :d => 4177773, :u => 232278672, :t => 1304082090 },
          { :id => 28388973, :d => 4177773, :u => 232278672, :t => 1304082091 }
        ]
      }
    end

    it "should be possible to parse the memory" do
      @frame.memory?.should be_true
      @frame.memory.should == {
        :wired => 25938,
        :active => 27620,
        :inactive => 11664,
        :free => 7983,
        :total => 73207,
        :swap_used => 3,
        :swap_total => 36861,
        :page_ins => 0,
        :page_outs => 0
      }
    end

    it "should be possible to parse the load" do
      @frame.load?.should be_true
      @frame.load.should == [0, 0, 0]
    end

    it "should be possible to parse the uptime" do
      @frame.uptime?.should be_true
      @frame.uptime.year.should == 2010
    end
    
    it "should be possible to parse the temps" do
      @frame.temps?.should be_true
      @frame.temps.should == [30, 52, 29, 50, 30, 64, 61]
    end
    
    it "should be possbile to parse the fans" do
      @frame.fans?.should be_true
      @frame.fans.should == [1999]
    end

    it "should be possible to parse the disks" do
      @frame.disks?.should be_true
      @frame.disks.should == [
        :label => "/", 
        :uuid => "/dev/vzfs",
        :free => 9226,
        :percent_used => 39.931
      ]
    end
    
    it "should be possible to request all data without getting an error" do
      @frame = Istat::Frames::MeasurementResponse.new(%Q{
        <?xml version="1.0" encoding="UTF-8"?><isr></isr>
      })
      @frame.cpu.should == nil
      @frame.network.should == nil
      @frame.memory.should == nil
      @frame.load.should == nil
      @frame.uptime.should == nil
      @frame.temps.should == nil
      @frame.fans.should == nil
      @frame.disks.should == nil
    end
  end
end
