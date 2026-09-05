# Docker LAMP – Quick Start

Docker LAMP sets up a complete local development environment: PHP in various versions, Apache, MariaDB/MySQL, phpMyAdmin and a mail server. SSL certificates for `*.test` domains are created automatically.

## Prerequisites

- Docker Engine
- Docker Compose Plugin
- Bash shell >= v4.0 (or WSL on Windows)
- On Mac OSX: Homebrew, gnu-getopt

### Preparation for Mac OS X
**Installing [Homebrew](https://brew.sh/):**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
**Installing `bash` (if < v4.0):**
```bash
brew install bash \
    && echo 'export PATH="$(brew --prefix)/bin:$PATH"' >> ~/.zshrc \
    && source ~/.zshrc
```
**Installing `gnu-getopt`:**
```bash
brew install gnu-getopt \
    && echo 'export PATH="$(brew --prefix)/opt/gnu-getopt/bin:$PATH"' >> ~/.zshrc \
    && source ~/.zshrc
```
---

## Installation – 4 Steps

### Step 1: Clone docker-lamp and create the project structure

Clone the tool to a central location:

```bash
sudo mkdir -p /opt/git
sudo chown -R $USER /opt/git
cd /opt/git
git clone https://github.com/degobbis/docker-lamp.git
```

Create your first customer project and copy the structure from the tool:

```bash
mkdir -p ~/Projects/Customer1
cp -r /opt/git/docker-lamp/data/* ~/Projects/Customer1/
cp /opt/git/docker-lamp/.env-example ~/Projects/Customer1/.env
```

### Step 2: Adjust the configuration for Customer1

Switch to the customer directory and edit the `.env`:

```bash
cd ~/Projects/Customer1
nano .env
```

Important settings:

```ini
# Working directory
APP_BASEDIR="$HOME/Projects/Customer1"

# Desired PHP versions (php56, php74, php80, php85)
PHP_TO_USE="php82 php85"

# Default PHP for port 80/443
MAP_PORT_80_443="php82"

# Database(s) (mariadb104, mariadb118, mysql57, mysql84 …)
DATABASE_TO_USE="mariadb118"

# Linux: user/group ID (otherwise file permission issues)
APP_USER_ID="$UID"
APP_GROUP_ID="$GID"

# Unique project name for Docker Compose
COMPOSE_PROJECT_NAME="customer1-lamp"
```

### Step 3: Start the server

Start docker-lamp from the customer project directory:

```bash
cd ~/Projects/Customer1
/opt/git/docker-lamp/docker-lamp start
```

The first start takes longer – images are pulled, and SSL certificates for `*.test` are created.

### Step 4: Verify in the browser

| URL | Description |
|-----|-------------|
| `http://localhost/` | PHP (default version) – points to the `www/` folder itself |
| `http://joomla.test/` | PHP (default version) – points to the `www/joomla` folder |

---

## Port Scheme

Each PHP version gets two ports:

| Scheme | HTTP | HTTPS |
|--------|------|-------|
| PHP 5.6 | `http://localhost:8056` | `https://localhost:8456` |
| PHP 7.4 | `http://localhost:8074` | `https://localhost:8474` |
| PHP 8.1 | `http://localhost:8081` | `https://localhost:8481` |
| PHP 8.2 | `http://localhost:8082` | `https://localhost:8482` |
| PHP 8.3 | `http://localhost:8083` | `https://localhost:8483` |
| PHP 8.4 | `http://localhost:8084` | `https://localhost:8484` |
| PHP 8.5 | `http://localhost:8085` | `https://localhost:8485` |

**Examples:**

```text
# PHP 8.2 – Customer1 default
http://localhost:8082/
https://localhost:8482/

# Joomla installation
http://joomla.test:8082/
https://joomla.test:8482/
```

`http://localhost` always points to `www/`

**Exception:**

| App | URL |
|--------|------|
| phpMyAdmin | `http://localhost:8000` or `https://localhost:8400` |
| Mailcatcher | `http://localhost:8025` |

**Note:** The ports `8000` and `8400` for `phpMyAdmin` and `8025` for the mailcatcher can be adjusted in the `.env`.

---

## Domain Mapping

Every default folder under `$APP_BASEDIR/www` is reachable as a domain:

| Folder | HTTP | HTTPS |
|--------|------|-------|
| `www/joomla/` | `http://joomla.test:80XX` | `https://joomla.test:84XX` |
| `www/wp/` | `http://wp.test:80XX` | `https://wp.test:84XX` |
| `www/wp-multisite/` | `http://wpms.test:80XX` | `https://wpms.test:84XX` |

### Subfolders → Subdomains

Subfolders are automatically turned into subdomains:

| Folder | HTTP | HTTPS |
|--------|------|-------|
| `www/joomla/testsite/` | `http://testsite.joomla.test:80XX` | `https://testsite.joomla.test:84XX` |
| `www/wp/testsite/` | `http://testsite.wp.test:80XX` | `https://testsite.wp.test:84XX` |

**Exception wp-multisite:** No subfolder required – WordPress captures subdomains. Configure in WP.

---

## BIND required for Domain Mapping

The automatic mapping (`joomla.test`, `wp.test`, etc.) only works **with BIND enabled**:

```ini
USE_BIND=1   # set in .env
```

BIND starts a local DNS server that automatically resolves `*.test`.

### Without BIND: adjust manually

**Windows:** `C:\Windows\System32\drivers\etc\hosts` - alternatively use Microsoft's [PowerToys](https://learn.microsoft.com/de-de/windows/powertoys/).  
**Linux/Mac OSX:** `/etc/hosts`

These files must be edited as administrator or root.

```bash
# /etc/hosts (or ~/.hosts on Mac OSX)
127.0.0.1  joomla.test wp.test wpms.test subdomain.joomla.test
```

**Important:** Wildcards (*.joomla.test) are not supported in the hosts file; every sub/domain must be written out explicitly (subdomain.joomla.test).

---

## Network Settings: DNS Resolver

To ensure that domain mapping works even when the BIND container is running, your operating system must use **your computer as a DNS resolver in front of the router**. BIND listens locally, answers all `*.test` and `*.local` requests, and forwards everything else to `DNS_FORWARDER` from the `.env`. The router’s IP address, for example, can be specified there.

### Linux with NetworkManager / systemd-resolved

**Intercepting the `.test` and `.local` TLDs:**
(systemd-resolved is the default in modern distributions)
```bash
sudo mkdir -p /etc/systemd/resolved.conf.d

sudo tee /etc/systemd/resolved.conf.d/local-test-domains.conf > /dev/null <<EOF
[Resolve]
DNS=127.0.0.1:53
Domains=~test ~local
EOF
```

### Mac OSX with mDNSResolver

**TLD `.test` und `.local` abfangen:**
```bash
sudo tee /etc/resolver/test > /dev/null <<EOF
nameserver 127.0.0.1
port 53
EOF

sudo tee /etc/resolver/local > /dev/null <<EOF
nameserver 127.0.0.1
port 53
EOF
```

### Windows

Adapter Options → IPv4 → Properties → DNS server:

- **Preferred DNS:** 127.0.0.1 (or IP of the BIND container)
- **Alternate DNS:** Router IP

**Important:** Without this entry, `*.test` and `*.local` remains unresolved, since the router does not know the domain. The local BIND must therefore come **before** the router.

---

## Important Commands

| Action | Command |
|--------|---------|
| Start server | `/opt/git/docker-lamp/docker-lamp start` |
| Stop server (data preserved) | `/opt/git/docker-lamp/docker-lamp stop` |
| Restart server | `/opt/git/docker-lamp/docker-lamp restart` |
| Shut down + DB backup | `/opt/git/docker-lamp/docker-lamp shutdown` |
| CLI in container | `/opt/git/docker-lamp/docker-lamp cli php82` |
| CLI as root | `/opt/git/docker-lamp/docker-lamp cli php82 -r` |
| Run command | `/opt/git/docker-lamp/docker-lamp cli php82 -r 'apk add nodejs'` |
| Update images | `/opt/git/docker-lamp/docker-lamp update-images` |
| Delete obsolete images | `/opt/git/docker-lamp/docker-lamp delete-obsolete-images` |

---

## Running Multiple Customers in Parallel

### Basic Principle

Docker-lamp is cloned **once** to `/opt/git/docker-lamp`. For each customer you create a separate project directory and copy the structure there:

```bash
# Customer1 (already done)
mkdir -p ~/Projects/Customer1
cp -r /opt/git/docker-lamp/data/* ~/Projects/Customer1/
cp /opt/git/docker-lamp/.env-example ~/Projects/Customer1/.env

# Create Customer2
mkdir -p ~/Projects/Customer2
cp -r /opt/git/docker-lamp/data/* ~/Projects/Customer2/
cp /opt/git/docker-lamp/.env-example ~/Projects/Customer2/.env
```

### Structure

```
/opt/git/docker-lamp/          # Tool (once)
└── data/                      # Template for customer projects

/home/user/Projects/
├── Customer1/                 # APP_BASEDIR Customer1
│   ├── .env                   # Own configuration
│   ├── ca/
│   ├── httpd/
│   ├── initDB/
│   ├── php/
│   └── www/
│       ├── joomla/
│       └── wp/
└── Customer2/                 # APP_BASEDIR Customer2
    ├── .env                   # Own configuration
    ├── ca/
    ├── httpd/
    ├── initDB/
    ├── php/
    └── www/
        └── ...
```

### Configuration for Customer1 and Customer2

**~/Projects/Customer1/.env:**

```ini
APP_BASEDIR="$HOME/Projects/Customer1"
PHP_TO_USE="php74 php82"
MAP_PORT_80_443="php82"
DATABASE_TO_USE="mariadb118"
COMPOSE_PROJECT_NAME="customer1-lamp"
USE_BIND=1
```

**~/Projects/Customer2/.env:**

```ini
APP_BASEDIR="$HOME/Projects/Customer2"
PHP_TO_USE="php82 php85"
MAP_PORT_80_443="php85"
DATABASE_TO_USE="mysql84"
COMPOSE_PROJECT_NAME="customer2-lamp"
USE_BIND=1
```

### Important Notes for Concurrent Operation

If you want to run multiple customers at the same time:

- **Only one BIND container** per machine – set `USE_BIND=0` in all other instances.
- **PHP versions, databases, phpMyAdmin, mailcatcher** need their own ports when used concurrently – adjustable via the `.env`.

**Recommendation:** For starters, only run one instance in parallel. Before switching to another customer, stop the current instance (`/opt/git/docker-lamp/docker-lamp shutdown`).

---

## The Concept of `APP_BASEDIR`

`APP_BASEDIR` is the **working directory** of each LAMP instance. All data, configurations and websites live there – completely independent of where the `docker-lamp` script is installed.

### Why do it this way?

1. **Tool and project separated:** Docker-lamp sits centrally in `/opt/git/docker-lamp`, your customer projects in `~/Projects/...`
2. **Git-friendly:** You version only `APP_BASEDIR` (your customer project), not the entire docker-lamp repo.
3. **Customer separation:** Each customer gets its own directory with its own `.env`, own databases and own SSL certificates.
4. **No conflicts:** Different customers can use different PHP versions, database versions and ports.

---

## Common Problems

### `ERROR: for customer2-lamp_bind Cannot start service bind`
Port conflict with an existing DNS.  
**Solution:** Disable BIND:
```ini
USE_BIND=0
```
or bind to a fixed IP:
```ini
DNS_A="*.local=<Machine IP e.g. 192.168.0.100>,*.test=192.168.0.100"
```

### Certificates are rejected
Import the Minica Root CA:
1. File: `$APP_BASEDIR/ca/minica-root-ca.pem`
2. Firefox: Settings → Privacy & Security → Certificates → Import
3. Chrome/Chromium: Settings → Security → Trusted Root Certification Authorities

**Recommendation:** To avoid importing multiple certificates for multiple customers, copy the files `$APP_BASEDIR/ca/minica-root-ca.pem` and `$APP_BASEDIR/ca/minica-root-ca-key.pem` into the respective customer folders. The certificates will then be automatically signed with the same key when the project starts.
