# docker-lamp

docker-lamp is a powerful collection of pre-built images, containers and scripts that use docker 
and docker compose to automate the creation of LAMP environments with different settings. 

When starting up docker-lamp it will: 
- create different docker containers
- create different PHP environments
- adds SSL/TLS to your local site
- make available a phpmyadmin interface to the databases
- deploy a local mail server with webmail functionality
- and create databases from sql scripts from a specified folder

## Requirements
### MacOS
- gnu-getopt

Install with Brew:
```
brew install gnu-getopt
```

Add to Your PATH variable:
```
sudo echo 'export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"' >> ~/.bash_profile
```

And finally add ```FLAGS_GETOPT_CMD```:
```
sudo echo 'export FLAGS_GETOPT_CMD="/usr/local/opt/gnu-getopt/bin/getopt"' >> ~/.bash_profile
```

Open a new terminal, or run ```. ~/. bash_profile``` in existing terminal to load changes.

Run ```echo $FLAGS_GETOPT_CMD``` to confirm it was actually set in your terminal.

## Documentation
Installation: https://blog.astrid-guenther.de/ubuntu_docker-lamp/2ubuntu-git-einrichten/
The blog describes how to use the previous version (main branch) and needs to be revised for version 2.0 (branch 2.0.0-dev). In any case, the section "Possible errors - ERROR: for docker-lamp_bind Cannot start service bind" is helpful.

### Main commands

#### Start
```
$ ./docker-lamp start
```

#### Stop
Shutdown and automatically create an .sql image of the databases 
```
$ ./docker-lamp shutdown
```

### Use browser to browse
- http://localhost:8000 - phpmyadmin
- http://localhost:8025 - mailhog webmail
- http://localhost/ - uses the PHP version configured as default
- https://localhost/ - uses the PHP version configured as default
- http://localhost:8074 - website using PHP7.4
- http://localhost:8074/phpinfo/ - PHP config of the PHP7.4 environment 
- http://localhost:8080 - website using PHP8.0
- https://localhost:8474 - website using PHP7.4 and SSL/TLS
- https://localhost:8480 - website using PHP8.0 and SSL/TLS
