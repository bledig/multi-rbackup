require File.join(File.dirname(__FILE__), 'spec_helper')

module MultiRbackup
  RSYNC_CMD_PREFIX = "rsync #{Rsyncer::RSYNC_OPTIONS} --log-file=/tmp/r.log \\\n"

  describe Rsyncer do

    def build_rsyncer
      syncer = Rsyncer.new
      syncer.backup_dirs = ['/tmp', '/home']
      syncer.dest_dir = '/dest_backup_dir'
      syncer.log_file = '/tmp/r.log'
      syncer.quiet = true
      syncer
    end
    
    describe "not valid variants" do
      before do
        @rsyncer = Rsyncer.new
      end

      it "empty Rsyncer should not validated" do
        lambda{ @rsyncer.validate }.should raise_error
      end

      it "missig dest_dir should not validated" do
        @rsyncer.backup_dirs = ['/tmp']
        lambda{ @rsyncer.validate }.should raise_error
      end

      it "missig backup_dirs should not validated" do
        @rsyncer.dest_dir = '/tmp'
        lambda{ @rsyncer.validate }.should raise_error
      end

      it "to and from_server should not validated" do
        @rsyncer.dest_dir = '/tmp'
        @rsyncer.backup_dirs = ['/tmp']
        @rsyncer.to_server = 'testserver'
        @rsyncer.from_server = 'testserver'
        lambda{ @rsyncer.validate }.should raise_error
      end
    end

    describe "command build" do
      before do
        @rsyncer = build_rsyncer
      end

      it "should correct command for local" do
        cmd = @rsyncer.make_rsync_command
        cmd.should == RSYNC_CMD_PREFIX + "/tmp /home /dest_backup_dir"
      end

      it "should correct command for local with excludes" do
        @rsyncer.add_exclude 'ex1'
        @rsyncer.add_exclude 'ex2'
        cmd = @rsyncer.make_rsync_command
        cmd.should == RSYNC_CMD_PREFIX + "--exclude=ex1 --exclude=ex2 \\\n/tmp /home /dest_backup_dir"
      end

      it "should correct command for to-server" do
        @rsyncer.to_server = 'testserver'
        cmd = @rsyncer.make_rsync_command
        cmd.should == RSYNC_CMD_PREFIX + "/tmp /home testserver:/dest_backup_dir"
      end

      it "should correct command for from-server" do
        @rsyncer.from_server = 'testserver'
        cmd = @rsyncer.make_rsync_command
        cmd.should == RSYNC_CMD_PREFIX + "testserver:'/tmp /home' /dest_backup_dir"
      end

      it "should correct command with add. rsync-options" do
        @rsyncer.add_rsync_options = ['--dry-run']
        cmd = @rsyncer.make_rsync_command
        cmd.should == RSYNC_CMD_PREFIX + "--dry-run \\\n/tmp /home /dest_backup_dir"
      end
    end

    describe "execute" do
      before do
        @rsyncer = build_rsyncer
      end

      it "should execute local" do
        @rsyncer.should_receive(:system_cmd).with(RSYNC_CMD_PREFIX + "/tmp /home /dest_backup_dir")
        @rsyncer.should_receive(:system_cmd).with("touch /dest_backup_dir")
        @rsyncer.execute
      end

      it "should execute from_server" do
        @rsyncer.from_server = 'testserver'
        @rsyncer.should_receive(:system_cmd).with(RSYNC_CMD_PREFIX + "testserver:'/tmp /home' /dest_backup_dir")
        @rsyncer.should_receive(:system_cmd).with("touch /dest_backup_dir")
        @rsyncer.execute
      end


      it "should execute to_server" do
        @rsyncer.to_server = 'testserver'
        @rsyncer.should_receive(:system_cmd).with(RSYNC_CMD_PREFIX + "/tmp /home testserver:/dest_backup_dir")
        @rsyncer.should_receive(:system_cmd).with("ssh testserver 'touch /dest_backup_dir'")
        @rsyncer.execute
      end
    end
  end

end
