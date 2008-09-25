# erzeugen eines Hardcopy-Snapshots eines Backups
# in ein Verzeichnis nach der Strategie
# akt Datum ist Monatserster in Verzeichnis backup-yyyy-mm-dd
# akt Datum ist Sonntag in Verzeichnis backup-week-nn (nn=Woche im Jahr)
# ansonsten in Verzeichnis backup-day-nn  (nn=Tag im Monat)
# 
# existiert das Verzeichnis schon, wird es vorher geloescht
# 
# Author: Bernd Ledig <bernd@ledig.info>
#
 
module MultiRbackup
  class SnapshotRotater

    attr_accessor :debug, :verbose, :quiet, :backup_date
    attr_reader :messages

    def initialize backup_dir, server=nil
      @backup_dir = backup_dir
      @server = server
      @messages = ""
    end

    def execute
      log "starte snapshot copy.." 

      #
      # ermitteln Snapshot-Verzeichnisname anhand des Datums und der Strategie
      #
      @backup_date ||= Time.now
      if @backup_date.day == 1
        # erster des Monats, also Monatskopie mit vollständigem Datum
        snap_to_dir = @backup_dir + '-' + @backup_date.strftime('%Y-%m-%d')
      elsif @backup_date.wday == 0
        # dann ist Sonmtag, also Wochenkopie
        snap_to_dir = @backup_dir + '-week-' + @backup_date.strftime('%W')
      else
        # dann Tageskopie
        snap_to_dir = @backup_dir + '-day-' + @backup_date.strftime('%d')
      end

      log "Delete old snapshot-dir: "+snap_to_dir
      system_cmd 'rm -rf', snap_to_dir

      log "Make Hardlink-Copy from #{@backup_dir} to #{snap_to_dir}"
      system_cmd 'cp -al',  @backup_dir, snap_to_dir

      log "snapshot copy finished"
    end


    private

    def system_cmd *args
      cmd = args.join(' ')
      cmd = "ssh #{@server} '#{cmd}'" if @server
      log "execute:  "+cmd if @verbose
      return if @debug
      if @quiet
        @messages << `#{cmd} 2>&1`
        execute_ok = ($? == 0)
      else
        execute_ok = system(cmd)
      end
      raise "Error by execute: '#{cmd}'" unless execute_ok
    end

    def log msg
      @messages << msg
      puts msg unless @quiet
    end
  end
end