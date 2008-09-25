require "rsyncer"
require "snapshot_rotater"

module MultiRbackup
  class BackupJob

    attr_accessor :last_exception
    attr_reader :name, :options

    def initialize(name, options)
      @name = name
      @options = options
      @rsyncer = Rsyncer.new(options)
      unless options[:no_rotate]
        @rotator = SnapshotRotater.new(options[:dest_dir], options[:to_server]) 
        @rotator.verbose = options[:verbose]
        @rotator.quiet = options[:quiet]
      end
    end

    def validate
      @rsyncer.validate
    end

    def execute
      begin
        @rsyncer.execute
        @rotator.execute if @rotator
      rescue => ex
        @last_exception = ex
        raise ex
      end
    end

    def messages
      msg = @rsyncer.messages
      msg << @rotator.messages unless options[:no_rotate]
      msg
    end

  end
end
