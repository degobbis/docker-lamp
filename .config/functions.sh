#!/usr/bin/env bash

usage() {
    clear
    echo "$(basename $0) $*"
    [ ! -z "$1" ] && eval "usage_$1" && exit 0
    echo
    warn "Usage:"
    success "-> $(basename $0) <command> [<parameters>]"
    echo
    warn "For more details about the allowed parameters use:"
    success "-> $(basename $0) <command> --help"
    echo
    warn "Commands:"
    warn "start"
    info "-> Uses 'docker-compose up -d --force-recreate' to start the server."
    info "-> If 'start' is used without parameters, the server is started with the globally defined settings from the '.env' file."
    info "-> If parameters are set, these will override the global settings. The phpmyadmin and mailhog containers always start."
    echo
    warn "restart"
    info "-> Uses 'docker-lamp halt && docker-lamp start [<parameters>]' to restart the server."
    echo
    warn "stop"
    info "-> Uses 'docker-compose down' to stop the server."
    echo
    warn "halt"
    info "-> Uses 'docker-compose down' to stop the server."
    info "-> However, unlike 'docker-lamp stop', the database volume is preserved and the databases are not backed up."
    info "-> Likewise, the files in the initDB folder are ignored by the next start."
    echo
    warn "update-images"
    info "-> Downloads the newest images globaly defined in the '.env' file, or set in the parameters."
    info "-> If parameters are set, these will override the global settings. The nwe images will be taged al latest."
    echo
    warn "delete-obsolete-images"
    info "-> Deletes obsolete images remaining after updated images."
    echo
    warn "cli <CONTAINER-NAME>"
    info "-> Uses 'docker-compose down' to stop the server."
    echo
    warn "backup-db <DB-NAME>"
    info "-> Uses 'docker-compose down' to stop the server."
    exit 0
}

usage_start() {
    DEBUG=1
    headline "Help for the command: start"
    echo
    warn "Usage:"
    success "-> $(basename $0) start [<parameters>]"
    echo
    info "-> Uses 'docker-compose up -d --force-recreate' to start the server."
    info "-> If 'start' is used without parameters, the server is started with the globally defined settings from the '.env' file."
    info "-> If parameters are set, these will override the global settings. The phpmyadmin and mailhog containers always start."
    echo
    echo
    warn "Parameters:"
    echo
    warn "-p, --php="
    info "-> Use the service names from the yaml file defined for the php versions."
    info "-> Put the value in quotes and separate multiple versions by space like 'php56 php73 php80'."
    echo
    warn "-H, --httpd="
    info "-> Use the service name from the yaml file defined for the httpd service like 'apache24'."
    echo
    warn "-d, --db="
    info "-> Use the service name from the yaml file defined for the database service like 'mariadb104' or 'mariadb105'."
    echo
    warn "-m, --map-80-443="
    info "-> Use the service name from the yaml file defined for the php version You want to map the default browser ports (80 and 443) for, like 'php74'."
    echo
    warn "--bind-on"
    info "-> If set, it will override the global configurtation in '.env' to 'USE_BIND=1'"
    echo
    warn "--bind-off"
    info "-> If set, it will override the global configurtationin '.env' to 'USE_BIND=0'"
    echo
    warn "--help"
    info "-> Show this help."
    echo
    echo
    info_b "Example:"
    success "-> $(basename $0) start --php='php74 php80' --httpd='apache24'"
    success "-> $(basename $0) start -p 'php74 php80' -H 'apache24'"
    info "-> Starts the server with php74 and php80, apache24, phpmyadmin, mailhog and the settings defined global in '.env' for db and bind."
    DEBUG=0
    exit 0
}

usage_restart() {
    DEBUG=1
    headline "Help for $(basename $0) restart"
    echo
    warn "Usage:"
    success "-> $(basename $0) restart [<parameters>]"
    echo
    info "-> Uses 'docker-lamp halt && docker-lamp start [<parameters>]' to restart the server."
    echo
    warn "For more details about the allowed parameters use:"
    success "-> $(basename $0) start --help"
    DEBUG=0
    exit 0
}

usage_stop() {
    DEBUG=1
    headline "Help for the command: stop"
    echo
    warn "Usage:"
    success "-> $(basename $0) stop [<parameters>]"
    echo
    info "-> Uses 'docker-compose down' to shutdown the server."
    info "-> Also all databases are saved into the folder 'initDB' and all created volumes will be deleted."
    info_b "-> IMPORTANT: All existing files will be overridden."
    echo
    echo
    warn "Parameters:"
    echo
    warn "-a, --archive"
    info "-> A copy of all databases is additionally archived in the subfolder within 'initDB' specified with the '-b or --backup-folder=' parameter."
    info "-> If this parameter is not set, the databases are archived by default in a subfolder, with the current date as name, in this format 'yyyy-mm-dd'."
    info "-> If set, it will override the global configurtation in '.env' to 'ARCHIVE_DATABASES=1'"
    echo
    warn "-b, --backup-folder="
    info "-> Set the subfolder within 'initDB', all databases will be archives into."
    echo
    echo
    info_b "Example:"
    success "-> $(basename $0) stop -a -b \"lt_\$(date +%Y-%m-%d)\""
    info "-> Saves all databases into 'initDB' and overwrites each of the existing ones and also archives a copy into 'initDB/lt_yyyy-mm-dd', then stops all containers and deletes all created volumes."
    echo
    success "-> $(basename $0) stop"
    info "-> Saves all databases into 'initDB' and overwrites each of the existing ones, then stops all containers and deletes all created volumes."
    DEBUG=0
    exit 0
}

usage_halt() {
    DEBUG=1
    headline "Help for the command: halt"
    echo
    warn "Usage: $(basename $0) halt [<parameters>]"
    echo
    info "-> Uses 'docker-compose down' to shutdown the server."
    info "-> However, unlike 'docker-lamp stop', the database volume is preserved and the databases are not backed up."
    info "-> Likewise, the files in the initDB folder are ignored by the next start."
    info "-> Anyway you can archive the databases."
    echo
    warn "You can still archive the databases."
    warn "For more details about how to, use:"
    success "-> $(basename $0) stop --help"
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
    tput setaf 1
    tput bold
    echo "ERROR:" "$@"
    tput sgr 0
    tput bel
}

warn() {
    tput setaf 3
    echo "$@"
    tput sgr 0
}

info() {
    tput setaf 7
    echo "$@"
    tput sgr 0
}

info_b() {
    tput setaf 7
    tput bold
    echo "$@"
    tput sgr 0
}

success() {
    tput setaf 2
    echo "$@"
    tput sgr 0
}

headline() {
    [ "$DEBUG" -eq 1 ] \
        && echo \
        && warn "--" "$@" "--"
}

log() {
    [ "$DEBUG" -eq 1 ] \
        && info "->" "$@"
}

add_yaml_to_load() {
    local YAML_LIST_TO_LOAD=${LOAD_YAML:-}
    local CONTAINER_PATH="$1"

    if [ -f "$APP_BASEDIR/$CONTAINER_PATH/config.yml" ]; then
        LOAD_YAML="$YAML_LIST_TO_LOAD $APP_BASEDIR/$CONTAINER_PATH/config.yml"
    elif [ -f "$DOCKER_COMPOSE_BASEDIR/.config/$CONTAINER_PATH/config.yml" ]; then
        LOAD_YAML="$YAML_LIST_TO_LOAD $DOCKER_COMPOSE_BASEDIR/.config/$CONTAINER_PATH/config.yml"
    else
        echo
        error "docker-compose configuration file for '$CONTAINER_PATH' not found!"
        warn "Searched for '$APP_BASEDIR/$CONTAINER_PATH/config.yml'"
        warn "and '$DOCKER_COMPOSE_BASEDIR/.config/$CONTAINER_PATH/config.yml'"
        exit 1
    fi
    log "$CONTAINER_PATH YAML loaded."
}

get_yaml_list() {
    local list=""

    for item in $1; do
        list="$list\n      - \"$item\""
    done

    printf "$list"
}
# find . -maxdepth 1 -type f ! -name "*.md" ! -name "*.txt"
