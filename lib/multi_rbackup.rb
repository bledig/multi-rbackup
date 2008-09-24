# Backup multiple Server per Rsync
# 
# Autor: Bernd Ledig <bernd@ledig.info>
#

lib_path = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)

require "backup_job"

module MultiRbackup
  VERSION = "0.0.1"
end

