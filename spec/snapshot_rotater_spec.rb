require File.join(File.dirname(__FILE__), 'spec_helper')

module MultiRbackup
  describe SnapshotRotater do

    it "should execute local" do
      @rotator = build_rotator

      @rotator.should_receive(:system_cmd).with("rm -rf", "/tmp/rbackup-day-24")
      @rotator.should_receive(:system_cmd).with("cp -al", '/tmp/rbackup', "/tmp/rbackup-day-24")
      @rotator.execute
    end

    it "should execute remote" do
      @rotator = build_rotator 'testserver'

      @rotator.should_receive(:system_cmd).with("rm -rf", "/tmp/rbackup-day-24")
      @rotator.should_receive(:system_cmd).with("cp -al", '/tmp/rbackup', "/tmp/rbackup-day-24")
      @rotator.execute
    end

    def build_rotator server=nil
      rotator = SnapshotRotater.new '/tmp/rbackup', server
      rotator.quiet = true
      rotator.backup_date = Time.mktime 2008,9,24
      rotator
    end
  end

end
