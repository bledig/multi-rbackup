= multi-rbackup

* http://multi-rbackup.working-it.de

== DESCRIPTION:

Backup multiple Sources/Servers with rsync

== FEATURES/PROBLEMS:

* backup from multiple Sources or Servers

== SYNOPSIS:

Usage:  multi-rbackup <options> config-file
Options:
   -l  --log-dir                  full filepath for logs, optional default is '/tmp'
   -v  --verbose                  print executed commands
       --debug                    debug on (test only)

Usage:  rsync-backup <options> dirs... [-- <rsync-options>]
Options:
   -f  --from-server server       get backup from this server
   -t  --to-server server         save backup to this server
   -d  --dest-dir dir             dest-dir for backups,  required
   -e  --exclude                  exclude pattern for rsync
   -l  --log-file                 full logfilepath, optional default is '/tmp/rsync-backup-<timestamp>.log'
   -n  --no-rotate                no snapshot-rotate of the backup
   -v  --verbose                  print executed commands
       --debug                    debug on (test only)
Attention! ONLY one option --from-server or --to-server are allowed.

== REQUIREMENTS:

* rsync 
* ssh if using remote Servers

== INSTALL:

* sudo gem install multi-rbackup

== LICENSE:

(The GPL V3)

