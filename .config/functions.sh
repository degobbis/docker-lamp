#!/usr/bin/env bash

usage() {
    [ ! -z "$1" ] && eval "usage_$1" && exit 0
    echo
    echo "Usage: $(basename $0) (start | stop | backup-db <DB-NAME> | cli <CONTAINER-NAME> | update-images | delete-obsolete-images) [<parameters>]

    Command:
      start    Uses 'docker-compose up -d --force-recreate' to start the server.

      If 'start' is used without options, the server is started with the globally defined settings from the '.env' file.
      If options are set, these will override the global settings.
      The phpmyadmin and mailhog containers always start.

      Parameters for 'start':
        -p | --php=      Use the service names from the yaml file defined for the php versions, separated by comma (,) like 'php56,php73,...'
                         IMPORTANT: No spaces allowed!
      -h | --httpd=      Use the service name from the yaml file defined for the httpd service like 'apache24'
      -h | --map-80-443= Use the service name from the yaml file defined for the httpd service like 'apache24'.
        -d | --db=       Use the service name from the yaml file defined for the database service like 'mariadb104' or 'mariadb105'
        --bind-off       If set, the bind service is not loaded.

      Example:
        start -p php74,php80 --httpd=apache24
        start -p 'php74,php80' --httpd='apache24'

        Starts the server with php74 and php80, apache24, phpmyadmin, mailhog and the container set global in '.env' for db and bind


    Command:
      stop    Uses 'docker-compose down' to stop the server.

      Parameters:
        --backup-folder=    Creates a backup of all databases to this subfolder.
        --clear=            Use the service names from the yaml file defined for the php versions, separated by spaces like 'php56 php73 ...'

      Example:
        stop --backup-folder='my-special-bkp-folder' --httpd='apache24'

        Starts the server with php74, apache24, phpmyadmin, mailhog and the container set global in '.env' for mysql and bind


      update-images
      delete-obsolete-images
      cli <CONTAINER-NAME>
      backup-db <DB-NAME>

    Examples:
      start [--php='php74 php80' --httpd='apache24' --bind=on|of]



      cli (httpd|php56|php73|php74|php80) [--composer|-c --root|-r]

      stop [-trqh -o 'rsync Optionen' -e Pfad -l Pfad] -c Pfad oder -s Pfad -d Pfad

	Pflicht:
	  entweder
	    -c, --config= 	Pfad zur Konfigurationsdatei.
	  oder
	    -s, --source= 	Pfad zum Verzeichnis oder Datei welche gesichert/wiederhergestellt werden soll.
	    -d, --dest= 	Pfad zum Verzeichnis in das gesichert/wiederhergestellt werden soll.

	Optional:
	    -o, --options= 	Überschreibt die Standardoptionen für 'rsync' komplett.
				Standardoptionen für die Sicherung sind: '-qahAEHPX --inplace --fake-super --numeric-ids --delete --modify-window=1'
				Genauere Informationen der Optionen können der Manpage von 'rsync' entnommen werden.
	    -l, --log= 		Pfad zur Logdatei. Diese wird jedesmal überschrieben und enthällt
				immer nur die Informationen der aktuellen Ausführung.
	    -e, --exclude= 	Pfad zur Datei mit einer liste von Verzeichnissen und Dateien,
				die von der Sicherung ausgeschlossen werden sollen. In der Datei je ein Eintrag pro Zeile.
				Wird bei '-r' oder '--restore' nicht verwendet.
	    -t, --test 		Einen Probelauf durchführen, ohne Änderungen vorzunehmen.
	    -r, --restore 	Diese Option ändert die Standardoptionen von 'rsync' für die Weiderherstellung.
				Wird eine Konfigurationsdatei verwendet, werden zusätzlich Start- und Zielverzeichnis vertauscht.
				Standardoptionen für die Wiederherstellung sind: 'qahAEHPX --inplace --numeric-ids --modify-window=1'
				Genauere Informationen der Optionen können der Manpage von 'rsync' entnommen werden.
	    -q, --quiet 	Ohne Abfrage einer Bestätigung durchführen.
	    -h, --help 		Diese Hilfe.
"
    exit 0
}

usage_start() {
    echo
    DEBUG=1
    headline "Help for $(basename $0) start"
    warn "Usage: $(basename $0) start [<parameters>]"

    echo "
    Command:
      start    Uses 'docker-compose up -d --force-recreate' to start the server.

      If 'start' is used without options, the server is started with the globally defined settings from the '.env' file.
      If options are set, these will override the global settings.
      The phpmyadmin and mailhog containers always start.

    Parameters for 'start':
      -p | --php=        Use the service names from the yaml file defined for the php versions, separated by comma (,) like 'php56,php73,...'.
                         IMPORTANT: No spaces allowed!
      -h | --httpd=      Use the service name from the yaml file defined for the httpd service like 'apache24'.
      -h | --map-80-443= Use the service name from the yaml file defined for the php version You want to map the default browser ports (80 and 443) for.
      -d | --db=         Use the service name from the yaml file defined for the database service like 'mariadb104' or 'mariadb105'.
      --bind-off         If set, the bind service is not loaded.
      --help             Show this help.

    Example:
      start --php=php74,php80 --httpd=apache24
      start -p 'php74,php80' -h 'apache24'

      Starts the server with php74 and php80, apache24, phpmyadmin, mailhog and the container set global in '.env' for db and bind.
"
    DEBUG=0
    exit 0
}

usage_restart() {
    echo
    DEBUG=1
    headline "Help for $(basename $0) restart"
    echo
    warn "Usage: $(basename $0) restart [<parameters>]"

    echo "
    Command:
      restart    Uses 'docker-lamp halt && docker-lamp start [<parameters>]' to restart the server.

      For more information about the allowed parameters, use 'docker-lamp start --help'.
"
    DEBUG=0
    exit 0
}

usage_halt() {
    echo
    DEBUG=1
    headline "Help for $(basename $0) halt"
    warn "Usage: $(basename $0) halt"

    echo "
    Command:
      halt    Uses 'docker-compose down' to stop the server.

      However, unlike 'docker-lamp stop', the database volume is preserved and the databases are not backed up. Likewise, the files in the initDB folder are ignored.
"
    DEBUG=0
    exit 0
}

usage_stop() {
    echo
    DEBUG=1
    headline "Help for $(basename $0) stop"
    warn "Usage: $(basename $0) stop [<parameters>]"

    echo "
    Command:
      stop    Uses 'docker-compose down' to stop the server.

      Also all volumes will be deleted after the databases are backed up into the initDB folder.

      Parameters:
        --backup-folder=    Creates a backup copy of all databases to this folder inside of initDB.
                            If not set, the copy of all database backups will be placed in a sub folder like
        --clear=            Use the service names from the yaml file defined for the php versions, separated by spaces like 'php56 php73 ...'

      Example:
        stop --backup-folder='my-special-bkp-folder' --httpd='apache24'

        Starts the server with php74, apache24, phpmyadmin, mailhog and the container set global in '.env' for mysql and bind


      update-images
      delete-obsolete-images
      cli <CONTAINER-NAME>
      backup-db <DB-NAME>

    Examples:
      start [--php='php74 php80' --httpd='apache24' --bind=on|of]



      cli (httpd|php56|php73|php74|php80) [--composer|-c --root|-r]

      stop [-trqh -o 'rsync Optionen' -e Pfad -l Pfad] -c Pfad oder -s Pfad -d Pfad

	Pflicht:
	  entweder
	    -c, --config= 	Pfad zur Konfigurationsdatei.
	  oder
	    -s, --source= 	Pfad zum Verzeichnis oder Datei welche gesichert/wiederhergestellt werden soll.
	    -d, --dest= 	Pfad zum Verzeichnis in das gesichert/wiederhergestellt werden soll.

	Optional:
	    -o, --options= 	Überschreibt die Standardoptionen für 'rsync' komplett.
				Standardoptionen für die Sicherung sind: '-qahAEHPX --inplace --fake-super --numeric-ids --delete --modify-window=1'
				Genauere Informationen der Optionen können der Manpage von 'rsync' entnommen werden.
	    -l, --log= 		Pfad zur Logdatei. Diese wird jedesmal überschrieben und enthällt
				immer nur die Informationen der aktuellen Ausführung.
	    -e, --exclude= 	Pfad zur Datei mit einer liste von Verzeichnissen und Dateien,
				die von der Sicherung ausgeschlossen werden sollen. In der Datei je ein Eintrag pro Zeile.
				Wird bei '-r' oder '--restore' nicht verwendet.
	    -t, --test 		Einen Probelauf durchführen, ohne Änderungen vorzunehmen.
	    -r, --restore 	Diese Option ändert die Standardoptionen von 'rsync' für die Weiderherstellung.
				Wird eine Konfigurationsdatei verwendet, werden zusätzlich Start- und Zielverzeichnis vertauscht.
				Standardoptionen für die Wiederherstellung sind: 'qahAEHPX --inplace --numeric-ids --modify-window=1'
				Genauere Informationen der Optionen können der Manpage von 'rsync' entnommen werden.
	    -q, --quiet 	Ohne Abfrage einer Bestätigung durchführen.
	    -h, --help 		Diese Hilfe.
"
    DEBUG=0
    exit 0
}

# Usage of tput
#
# tput bold # Select bold mode
# tput dim  # Select dim (half-bright) mode
# tput smul # Enable underline mode
# tput rmul # Disable underline mode
# tput rev  # Turn on reverse video mode
# tput smso # Enter standout (bold) mode
# tput rmso # Exit standout mode
#
# tput setab [1-7] # Set the background colour using ANSI escape
# tput setaf [1-7] # Set the foreground colour using ANSI escape
# tput sgr0        # Reset text format to the terminal's default
# tput bel         # Play a bell
#
# Num  Colour
# 0    black
# 1    red
# 2    green
# 3    yellow
# 4    blue
# 5    magenta
# 6    cyan
# 7    white

error() {
    echo && echo "$(tput setaf 1; tput bold) ERROR:" "$@" "$(tput sgr 0)" && tput bel
}

warn() {
    echo "$(tput setaf 3) ->" "$@" "$(tput sgr 0)"
}

info() {
    echo "$(tput sgr 0) ->" "$@"
}

success() {
    echo && echo "$(tput setaf 2) ->" "$@" "$(tput sgr 0)"
}

headline() {
    [ "$DEBUG" -eq 1 ] && echo && echo "$(tput setaf 3) --" "$@" "--$(tput sgr 0)"
}

log() {
    [ "$DEBUG" -eq 1 ] && echo "$(tput setaf 7) ->" "$@" "$(tput sgr 0)"
}

get_yaml_list() {
    local list=""

    for item in $1; do
        list="$list\n      - \"$item\""
    done

    printf "$list"
}
# find . -maxdepth 1 -type f ! -name "*.md" ! -name "*.txt"
