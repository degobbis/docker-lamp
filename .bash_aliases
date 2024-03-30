###
# Start - docker-lamp commands
###

# Wrapper.
alias docker-lamp='/srv/git/docker-lamp/docker-lamp'

# dl-start - Starts docker-lamp.
# Use it inside the project directory where the .env is.
alias dl-start='docker-lamp start'

# dl-stop - Stops docker-lamp.
# Removes all container and volumes except the database volume.
# Switching the database between MariaDB and MySQL should not be done here.
# Use it inside the project directory where the .env is.
alias dl-stop='docker-lamp stop'

# dl-down - Stops docker-lamp.
# Saves all databases to initDB and removes the database volume.
# Use it inside the project directory where the .env is.
# Is required if the database is to be switched between MariaDB and MySQL.
alias dl-down='docker-lamp shutdown'

# dl-cli - Command to call up the terminal of the respective container.
# Use it inside the project directory where the .env is.
alias dl-cli='docker-lamp cli'

# dl-restart - Stops and starts docker-lamp in one go.
# Use it inside the project directory where the .env is.
alias dl-restart='docker-lamp restart'

# dl-update - Updates the images of docker-lamp.
# Use it inside the project directory where the .env is.
alias dl-update='docker-lamp update-images'

# dl-clear - Deletes the obsolete docker-lamp images after the update.
# Use it inside the project directory where the .env is.
alias dl-clear='docker-lamp delete-obsolete-images'

# dl-init - Switches to the project directory before starting docker-lamp.
# If the project directory is different from '/srv/', this must be adjusted here.
alias dl-init='echo "- Change directory to /srv/"; cd /srv/; dl-start'

###
# End - docker-lamp commands
###
