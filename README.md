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

## Documentation
Installation: https://blog.astrid-guenther.de/en/ubuntu-docker-lamp-einrichten/

### Main commands

#### Start
```
$ docker-lamp start
```

#### Stop
Shutdown and automatically create an .sql image of the databases 
```
$ docker-lamp shutdown
```

### Use browser to browse
- http://localhost:8000 - phpmyadmin
- http://localhost:8025 - mailhog webmail
- http://localhost:8074 - website using PHP7.4
- http://localhost:8074/phpinfo/ - PHP config of the PHP7.4 environment 
- http://localhost:8080 - website using PHP8.0
- https://localhost:8474 - website using PHP7.4 and SSL/TLS
- https://localhost:8480 - website using PHP8.0 and SSL/TLS
