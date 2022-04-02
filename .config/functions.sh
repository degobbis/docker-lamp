#!/usr/bin/env bash

. $DOCKER_LAMP_BASEDIR/.config/docker-lamp-completion.bash

usage() {
    warn "-- Help for the command:" "$(basename $0)" "$*" "--"
    echo
    [ ! -z "$1" ] && eval "usage_$1" && exit 0
    warn "Usage:"
    success "-> $(basename $0) <command> [<parameters>]"
    echo
    warn "For more details about the allowed parameters use:"
    success "-> $(basename $0) <command> --help"
    echo
    warn "Commands:"
    warn "start [<parameters>]"
    info "-> If 'start' is used without parameters, the server is started with the globally defined settings from the '.env' file."
    info "-> If parameters are set, these will override the global settings. The phpmyadmin and mailhog containers always start."
    echo
    warn "restart"
    info "-> Restarts the server with the same configuration as started before."
    echo
    warn "shutdown [<parameters>]"
    info "-> Shuts down the server completely deleting also all volumes created."
    info "-> If not other set, all databases will be saved before."
    echo
    warn "stop"
    info "-> Stops the server."
    info "-> However, unlike 'shutdown', the database volume is preserved and the databases are not saved before."
    info "-> Likewise, the files in the 'initDB' folder are ignored by the next start."
    echo
    warn "update-images"
    info "-> Downloads the newest images globally defined in the '.env' file, or set in the parameters."
    info "-> If parameters are set, these will override the global settings. The new images will be tagged all latest."
    echo
    warn "delete-obsolete-images"
    info "-> Deletes obsolete images remaining after updated images."
    echo
    warn "cli <CONTAINER-NAME> [<parameters>][ '<COMMAND-TO-PASS>']"
    info "-> Uses 'docker exec -it <CONTAINER-NAME>' to launch into the cli in the container, or to execute the passed command."
    info "-> Use single quotes ' to pass the command to the container to be executed in it."
    echo
    warn "save-db <DB-NAME>"
    info "-> Uses 'docker-compose down' to stop the server."
    exit 0
}

usage_start() {
    warn "Usage:"
    success "-> $(basename $0) start [<parameters>]"
    echo
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
    info "-> If set, it will override the global configuration in '.env' to 'USE_BIND=1'"
    echo
    warn "--bind-off"
    info "-> If set, it will override the global configuration in '.env' to 'USE_BIND=0'"
    echo
    warn "--help"
    info "-> Show this help."
    echo
    echo
    info_b "Example:"
    success "-> $(basename $0) start --php='php74 php80' --httpd='apache24'"
    success "-> $(basename $0) start -p 'php74 php80' -H 'apache24'"
    info "-> Starts the server with php74 and php80, apache24, phpmyadmin, mailhog and the settings defined global in '.env' for db and bind."
    exit 0
}

usage_restart() {
    warn "Usage:"
    success "-> $(basename $0) restart"
    echo
    info "-> Restarts the server with the same configuration as started before."
    exit 0
}

usage_shutdown() {
    warn "Usage:"
    success "-> $(basename $0) shutdown [<parameters>]"
    echo
    info "-> Shuts down the server completely deleting also all volumes created."
    info "-> If not other set, all databases will be saved before."
    info_b "-> IMPORTANT: All existing files in 'initDB' will be overridden."
    echo
    echo
    warn "Parameters:"
    echo
    warn "-s, --skip-save-db"
    info "-> If this option is set, no databases and no archives are saved."
    echo
    warn "-a, --archive"
    info "-> A copy of all databases is additionally archived in the subfolder within 'initDB' specified with the '-b or --backup-folder=' parameter."
    info "-> If this parameter is not set, the databases are archived by default in a subfolder, with the current date as name, in this format 'yyyy-mm-dd'."
    info "-> If set, it will override the global configuration in '.env' to 'ARCHIVE_DATABASES=1'"
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
    exit 0
}

usage_stop() {
    warn "Usage: $(basename $0) stop"
    echo
    info "-> Stops the server."
    info "-> However, unlike 'shutdown', the database volume is preserved and the databases are not saved before."
    info "-> Likewise, the files in the 'initDB' folder are ignored by the next start."
    echo
    warn "Anyway, if you like to save (and archive) the databases,"
    warn "You need to use '$(basename $0) save-db [<parameters>]' before."
    echo
    warn "For more details about how to, use:"
    success "-> $(basename $0) save-db --help"
    exit 0
}

usage_cli() {
    warn "Usage: $(basename $0) cli"
    echo
    warn "cli <CONTAINER-NAME> [<parameters>][ '<COMMAND-TO-PASS>']"
    info "-> Uses 'docker exec -it <CONTAINER-NAME>' to launch into the cli in the container, or to execute the passed command."
    info "-> Use single quotes ' to pass the command to the container to be executed in it."
    echo
    echo
    warn "Parameters:"
    echo
    warn "-r, --as-root"
    info "-> If this option is set, the cli is startet as root, elsewhere as user."
    echo
    warn "-x, --xdebug"
    info "-> Launch into cli with xdebug enabled."
    echo
    echo
    info_b "Example:"
    success "-> $(basename $0) cli php80 -r 'apk add nodejs npm'"
    info "-> This will install in the 'php80' container the packages 'nodejs' and 'npm'."
    echo
    info_b "Same as:"
    success "-> $(basename $0) cli php80 -r"
    info "-> php80:/srv/www# add apk nodejs npm"
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

log_b() {
    [ "$DEBUG" -eq 1 ] \
        && info_b "->" "$@"
}

log_s() {
    [ "$DEBUG" -eq 1 ] \
        && success "->" "$@"
}

log_w() {
    [ "$DEBUG" -eq 1 ] \
        && warn "->" "$@"
}

add_yaml_to_load() {
    local YAML_LIST_TO_LOAD=${LOAD_YAML:-}
    local CONTAINER_PATH="$1"

    if [ -f "$APP_BASEDIR/$CONTAINER_PATH/config.yml" ]; then
        LOAD_YAML="$YAML_LIST_TO_LOAD $APP_BASEDIR/$CONTAINER_PATH/config.yml"
    elif [ -f "$DOCKER_LAMP_BASEDIR/.config/$CONTAINER_PATH/config.yml" ]; then
        LOAD_YAML="$YAML_LIST_TO_LOAD $DOCKER_LAMP_BASEDIR/.config/$CONTAINER_PATH/config.yml"
    else
        echo
        error "docker-compose configuration file for '$CONTAINER_PATH' not found!"
        warn "Searched for '$APP_BASEDIR/$CONTAINER_PATH/config.yml'"
        warn "and '$DOCKER_LAMP_BASEDIR/.config/$CONTAINER_PATH/config.yml'"
        exit 1
    fi

    log_s "$CONTAINER_PATH YAML loaded."
}

get_yaml_list() {
    local list=""

    for item in $1; do
        list="$list\n      - \"$item\""
    done

    printf "$list"
}

start_server() {
    local _db_volume_exist=$(docker volume ls --filter=name=$COMPOSE_PROJECT_NAME | grep "${COMPOSE_PROJECT_NAME}_db-data-dir")

    create_certs

    warn "Start server:"
    $DOCKER_COMPOSE_CALL up -d --force-recreate \
        && success "Server started."

    [ -z "$_db_volume_exist" ] && restore_db
}

restart_server() {
    ( [ -f "$DOCKER_COMPOSE_YAML" ] && [ -z "$($DOCKER_COMPOSE_CALL ps -q)" ] ) \
        && warn "Server is not running." && exit 0

    warn "Stop server:"
    $DOCKER_COMPOSE_CALL down
    warn "Removing volumes:"
    docker volume ls --filter=name=$COMPOSE_PROJECT_NAME \
        | grep -v 'db-data-dir' | awk 'NR > 1 {print $2}' \
        | xargs docker volume rm --force \
        | xargs echo "Volumes removed:"
    create_certs
    warn "Start server:"
    $DOCKER_COMPOSE_CALL up -d --force-recreate \
        && success "Server restarted."
}

shutdown_server() {
    ( [ -f "$DOCKER_COMPOSE_YAML" ] && [ -z "$($DOCKER_COMPOSE_CALL ps -q)" ] ) \
        && warn "Server is not running." \
        && exit 0

    [ -z "$SKIP_SAVE_DATABASES" ] \
        && save_db \
        || success "Skip save database(s)."

    warn "Shutdown server:"
    $DOCKER_COMPOSE_CALL down -v
    success "Server shut down."
}

stop_server() {
    ( [ -f "$DOCKER_COMPOSE_YAML" ] && [ -z "$($DOCKER_COMPOSE_CALL ps -q)" ] ) \
        && warn "Server is not running." && exit 0

    warn "Stop server:"
    $DOCKER_COMPOSE_CALL down
    warn "Removing volumes:"
    docker volume ls --filter=name=$COMPOSE_PROJECT_NAME \
        | grep -v 'db-data-dir' | awk 'NR > 1 {print $2}' \
        | xargs docker volume rm --force \
        | xargs echo "Volumes removed:"
    success "Server is stoped."
}

save_db() {
    [ -z "$($DOCKER_COMPOSE_CALL ps -q $DATABASE_TO_USE)" ] \
        && warn "Database server '$DATABASE_TO_USE' is not running." && exit 0

    local envs=""
    [ "$ARCHIVE_DATABASES" -eq 1 ] && env="-e ARCHIVE=1 "
    [ ! -z "$ARCHIVE_FOLDER" ] && env="${env}-e ARCHIVE_FOLDER=$ARCHIVE_FOLDER "

    local shell="sh"
    case "$DATABASE_TO_USE" in
        mysql57|mysql80)
            shell="bash"
            ;;
    esac

    warn "Save databases:"
    docker exec -it --privileged ${envs}${COMPOSE_PROJECT_NAME}_db /usr/bin/env $shell -c "/usr/local/bin/backup-databases"
}

delete_obsolete_images() {
    local OBSOLETE_IMAGES="$(docker images -f "dangling=true" -q)"

    [ -z "$OBSOLETE_IMAGES" ] \
        && success "No obsolete images found." \
        && exit 0

    warn "Found obsolete Images:"
    info "$OBSOLETE_IMAGES"

    local ERROR_DELETE_OBSOLETE="$(docker rmi $OBSOLETE_IMAGES >/dev/null 2>&1)"

    [ -z "$ERROR_DELETE_OBSOLETE" ] \
        && success "Obsolete images deleted." \
        || error "$ERROR_DELETE_OBSOLETE"
}

create_certs() {
    local MINICA_BASEDIR="$APP_BASEDIR/ca"

    [ ! -z "$SSL_LOCALDOMAINS" ] \
        && MINICA_DEFAULT_DOMAINS="$MINICA_DEFAULT_DOMAINS,$SSL_LOCALDOMAINS"

    [ ! -z "$SSL_DOMAINS" ] \
        && MINICA_DEFAULT_DOMAINS="$MINICA_DEFAULT_DOMAINS $SSL_DOMAINS"

    MINICA_DEFAULT_DOMAINS="$(echo "$MINICA_DEFAULT_DOMAINS" | sed "s/, /,/g")"

    warn "Start creating SSL certificates:"
    for domain in $MINICA_DEFAULT_DOMAINS; do
        info "Create certificate for:" "$domain"
        docker run --user $APP_USER_ID -it --rm \
            -v "$MINICA_BASEDIR:/certs" \
            degobbis/minica \
            --ca-cert minica-root-ca.pem \
            --ca-key minica-root-ca-key.pem \
            --domains $domain
        echo
    done

    success "All certificates created."
}

restore_db() {
    [ -z "$($DOCKER_COMPOSE_CALL ps -q $DATABASE_TO_USE)" ] \
        && warn "Database server '$DATABASE_TO_USE' is not running." && exit 0

    local shell="sh"
    case "$DATABASE_TO_USE" in
        mysql57|mysql80)
            shell="bash"
            ;;
    esac

    warn "Restore databases:"
    docker exec -it --privileged ${COMPOSE_PROJECT_NAME}_db /usr/bin/env $shell -c "/usr/local/bin/restore-databases"

}

update_images() {
    local yaml_file_for_update="$DOCKER_LAMP_BASEDIR/.config/update-images.yml"

    [ -f "$DOCKER_COMPOSE_YAML" ] && yaml_file_for_update="$DOCKER_COMPOSE_YAML"

    docker-compose -f $yaml_file_for_update pull
}

cli_container() {
    local params="--user $APP_USER_ID "
    local container_name="$CLI_CONTAINER"
    local shell="sh"

    # TODO: Set it only on CLI call for CLI debugging
    local env=' -e XDEBUG_CONFIG= '

    [ "$CLI_CONTAINER" = "php80" ] && env+=' -e XDEBUG_SESSION=1 '

    if [ "$CLI_CONTAINER" = "db" ]; then
        container_name="$DATABASE_TO_USE"

        case "$DATABASE_TO_USE" in
            mysql57|mysql80)
                shell="bash"
                ;;
        esac
    fi

    [ -z "$($DOCKER_COMPOSE_CALL ps -q $container_name)" ] \
        && warn "The container '$CLI_CONTAINER' is not running." && exit 0

    [ "${AS_ROOT:-0}" -eq 1 ] && params="--privileged "
    [ "${CLI_WITH_XDEBUG:-0}" -eq 0 ] && env=""

    headline "Before starting CLI for '$CLI_CONTAINER'"
    log "shell: $shell"
    log "env: $env"
    log "params: $params"
    log "COMMAND_TO_PASS: $COMMAND_TO_PASS"

    [ ! -z "$COMMAND_TO_PASS" ] \
        && docker exec -it ${params}${env}${COMPOSE_PROJECT_NAME}_${CLI_CONTAINER} /usr/bin/env ${shell} -cx "$COMMAND_TO_PASS" \
        || docker exec -it ${params}${env}${COMPOSE_PROJECT_NAME}_${CLI_CONTAINER} /usr/bin/env ${shell}
}

quote () {
    local quoted=${1//\'/\'\\\'\'};
    printf "'%s'" "$quoted"
}

# find . -maxdepth 1 -type f ! -name "*.md" ! -name "*.txt"
