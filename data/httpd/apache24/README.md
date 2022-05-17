At this place you can add your own apache vhosts configurations (file ordering will be respected).

To add a PHP version like 7.2.x, this is the right place to do this.  
Write them to a file with the extension ``.conf``.

Example: ``10-php72.conf``

You can use one of the configuration files placed in .config/httpd/apache24/vhosts as a base.

As a new PHP version you need to add the listner for the ports at the top of the file.

Example:  
``Listen 8072``  
``Listen 8472``

Don't forgett do add it also in a docker-compose.override.yml.

---

It's also possible to use the macros for the automaticaly creation of vhosts for all original PHP versions.  
It's needed for adding external domains.

Example: ``00-external-domains.conf``

Configure the Use statement with your external domain followed by the aliases.

Also needed is to add your domains in your .env file for SSL_DOMAINS and EXTRA_HOSTS.

Example for .env file:  
``EXTRA_HOSTS=example.org=127.0.0.1,www.example.org=127.0.0.1,other-example.org=127.0.0.1,www.example.org=127.0.0.1``  
``SSL_DOMAINS=example.org,www.example.org other-example.org,www.other-example.org``

Example for Document Root folder is:  
``./data/www/example.org`` or example.org in the path of your APP_BASEDIR variable.  
``./data/www/other-example.org`` or other-example.org in the path of your APP_BASEDIR variable.

Example call is:  
``Use VHost example.org ""``  
``Use VHost other-example.org ""``

You can set aliases for the domain in the second parameter

Example for Document Root folder is:  
``./data/www/example.org`` or example.org in the path of your WWW_BASEDIR variable.  
The domain other-example.org will be set as alias for example.org.  
Additionaly we will catch all subdomains of example.org

Example call is:  
``Use VHost example.org "*.example.org other-example.org"``

The subdomain www. will be set automatically for all domains (not aliases) called here.  
Separate multiple aliases with a space. Surround multiple aliases with double quotation marks ("").  
If no alias is needed, set empty double quotation marks!
