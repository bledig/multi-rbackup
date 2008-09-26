require 'fileutils'

module MultiRbackup

  # Attributes
  #   from_server :       get backup from this server
  #   to_server :         save backup to this server
  #   dest_dir :          dest-dir for backups,  required
  #   backup_dirs :       Array with dir-names to backup
  #   log_file :          full logfilepath, optional, default is '/tmp/rsync-backup-<timestamp>.log'
  #   add_rsync_options : optional Array with org. rsync options
  #   verbose :           print executed commands
  #
  # use global Var $debug
  #
  class Rsyncer

    RSYNC_OPTIONS = "--archive --stats --human-readable --compress --numeric-ids \\\n"+
                    "--delete --delete-excluded --partial --one-file-system \\\n"+
                    "--log-file-format=\"%i %8l %8b %n\"".freeze

    attr_accessor :from_server, :to_server, :dest_dir, :backup_dirs, :excludes, 
                  :log_file, :add_rsync_options, :verbose, :quiet


    attr_reader :messages

    # Attributes
    #   :from_server :       get backup from this server
    #   :to_server :         save backup to this server
    #   :dest_dir :          dest-dir for backups,  required
    #   :backup_dirs :       Array with dir-names to backup
    #   :log_file :          full logfilepath, optional, default is '/tmp/rsync-backup-<timestamp>.log'
    #   :add_rsync_options : optional Array with org. rsync options
    #   :verbose :           print executed commands
    #   :quiet :              no messages
    #
    def initialize options=nil
      @validated = false
      if options
        [:from_server, :to_server, :dest_dir, :backup_dirs, :excludes,
         :log_file, :add_rsync_options, :verbose, :quiet].each do |attr| 
          self.send("#{attr}=", options[attr])
        end
      end
      @excludes ||= []
      @messages = ""
    end


    def add_exclude exclude
      @excludes << exclude
    end


    def validate
      return if @validated
      errors = []
      errors << 'Destination-dir required!' unless @dest_dir
      errors << 'Backup-dirs required!' if @backup_dirs.nil? || @backup_dirs.empty?
      errors << 'Only from_server OR to_server is allowd!' if @from_server && @to_server
      raise errors.join(', ') unless errors.empty?
      @validated = true
    end


    def make_rsync_command
      @log_file ||= "/tmp/rsync-backup-#{Time.now.strftime('%Y%m%d%H%M%S')}.log"

      @rsync_options = "#{RSYNC_OPTIONS} --log-file=#{log_file}"

      unless @excludes.empty?
        @rsync_options << " \\\n"
        @rsync_options << @excludes.collect{|e| "--exclude=#{e}" }.join(' ')
      end

      if @add_rsync_options && !@add_rsync_options.empty?
        @rsync_options << " \\\n"
        @rsync_options << @add_rsync_options.join(' ')
      end

      @source = @backup_dirs.join(' ')
      @source = "#{@from_server}:'#{@source}'" if @from_server

      #@dest_dir = File.join @dest_dir, 'backup'
      @destination = @dest_dir
      @destination = "#{@to_server}:#{@destination}" if @to_server

      @rsync_cmd = "rsync #{@rsync_options} \\\n#{@source} #{@destination}"
    end


    def execute
      validate
      make_rsync_command

      log <<-EOT
==========================================================================
backup ........ #{@source}
to............. #{@destination}
rsync-options.. \n\t#{@rsync_options.gsub(/[\n]/, "\n\t")} 
==========================================================================
EOT

      FileUtils.rm_f(@log_file) unless $debug
      system_cmd(@rsync_cmd)


      # Datum des Backups setzen
      cmd = "touch #{@dest_dir}"
      cmd = "ssh #{@to_server} '#{cmd}'" if @to_server
      system_cmd(cmd)
    end

    private

      def system_cmd cmd
        log cmd if @verbose
        return if $debug
        if @quiet
          @messages << `#{cmd} 2>&1`
          @messages << "\n"
        else
          system(cmd)
        end
        # rsnyc-exit-code 24-'Partial transfer due to vanished source files' to ignore
        execute_ok = ($?.exitstatus == 0 || $?.exitstatus == 24)
        raise "Error by execute: '#{cmd}'" unless execute_ok
      end

      def log msg
        @messages << msg
        @messages << "\n"
        puts msg unless @quiet
      end
  end
end
