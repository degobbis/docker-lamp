# Docker LAMP – Schnellstart

Docker LAMP richtet eine vollständige lokale Entwicklungsumgebung ein: PHP in verschiedenen Versionen, Apache, MariaDB/MySQL, phpMyAdmin und einen Mailserver. SSL-Zertifikate für `*.test`-Domains werden automatisch erstellt.

## Voraussetzungen

- Docker Engine
- Docker Compose Plugin
- Bash Shell >= v4.0 (oder WSL bei Windows)
- Auf Mac OSX: Homebrew, gnu-getopt

### Vorbereitung auf Mac OSX
**Installation von [Homebrew](https://brew.sh/de/):**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
**Installation von `bash` (falls < v4.0):**
```bash
brew install bash \
    && echo 'export PATH="$(brew --prefix)/bin:$PATH"' >> ~/.zshrc \
    && source ~/.zshrc
```
**Installation von `gnu-getopt`:**

```bash
brew install gnu-getopt \
    && echo 'export PATH="$(brew --prefix)/opt/gnu-getopt/bin:$PATH"' >> ~/.zshrc \
    && source ~/.zshrc
```

---

## Installation – 4 Schritte

### Schritt 1: docker-lamp klonen und Projektstruktur anlegen

Klone das Tool an einen zentralen Ort:

```bash
sudo mkdir -p /opt/git
sudo chown -R $USER /opt/git
cd /opt/git
git clone https://github.com/degobbis/docker-lamp.git
```

Lege dein erstes Kundenprojekt an und kopiere die Struktur vom Tool:

```bash
mkdir -p ~/Projekte/Kunde1
cp -r /opt/git/docker-lamp/data/* ~/Projekte/Kunde1/
cp /opt/git/docker-lamp/.env-example ~/Projekte/Kunde1/.env
```

### Schritt 2: Konfiguration für Kunde1 anpassen

Wechsle in das Kundenverzeichnis und passe die `.env` an:

```bash
cd ~/Projekte/Kunde1
nano .env
```

Wichtige Einstellungen:

```ini
# Arbeitsverzeichnis
APP_BASEDIR="$HOME/Projekte/Kunde1"

# Gewünschte PHP-Versionen (php56, php74, php80, php85)
PHP_TO_USE="php82 php85"

# Standard-PHP für Port 80/443
MAP_PORT_80_443="php82"

# Datenbank(en) (mariadb104, mariadb118, mysql57, mysql84 …)
DATABASE_TO_USE="mariadb118"

# Linux: Benutzer-/Gruppen-ID (sonst Dateien-Rechte-Probleme)
APP_USER_ID="$UID"
APP_GROUP_ID="$GID"

# Eindeutiger Projektname für Docker Compose
COMPOSE_PROJECT_NAME="kunde1-lamp"
```

### Schritt 3: Server starten

Starte docker-lamp aus dem Kundenprojektverzeichnis:

```bash
cd ~/Projekte/Kunde1
/opt/git/docker-lamp/docker-lamp start
```

Erster Start dauert länger – Images werden geladen, SSL-Zertifikate für `*.test` erstellt.

### Schritt 4: Im Browser prüfen

| URL | Beschreibung |
|-----|--------------|
| `http://localhost/` | PHP (Standard-Version) – zeigt auf `www/`-Ordner selbst |
| `http://joomla.test/` | PHP (Standard-Version) – zeigt auf `www/joomla`-Ordner |

---

## Port-Schema

Jede PHP-Version bekommt zwei Ports:

| Scheme | HTTP | HTTPS |
|--------|------|-------|
| PHP 5.6 | `http://localhost:8056` | `https://localhost:8456` |
| PHP 7.4 | `http://localhost:8074` | `https://localhost:8474` |
| PHP 8.1 | `http://localhost:8081` | `https://localhost:8481` |
| PHP 8.2 | `http://localhost:8082` | `https://localhost:8482` |
| PHP 8.3 | `http://localhost:8083` | `https://localhost:8483` |
| PHP 8.4 | `http://localhost:8084` | `https://localhost:8484` |
| PHP 8.5 | `http://localhost:8085` | `https://localhost:8485` |

**Beispiele:**

```text
# PHP 8.2 – Kunde1 Standard
http://localhost:8082/
https://localhost:8482/

# Joomla-Installation
http://joomla.test:8082/
https://joomla.test:8482/
```

`http://localhost` zeigt immer auf `www/`

**Ausnahme:**

| App | URL |
|--------|------|
| phpMyAdmin | `http://localhost:8000` oder `https://localhost:8400` |
| Mailcatcher | `http://localhost:8025` |

**Hinweis:** Die Ports `8000` und `8400` für `phpMyAdmin` und `8025` für den Mailcatcher können in der `.env` angepasst werden.

---

## Domain-Mapping

Jeder Standard-Ordner unter `$APP_BASEDIR/www` ist als Domain erreichbar:

| Ordner | HTTP | HTTPS |
|--------|------|-------|
| `www/joomla/` | `http://joomla.test:80XX` | `https://joomla.test:84XX` |
| `www/wp/` | `http://wp.test:80XX` | `https://wp.test:84XX` |
| `www/wp-multisite/` | `http://wpms.test:80XX` | `https://wpms.test:84XX` |

### Unterordner → Subdomains

Unterordner werden automatisch zur Subdomain:

| Ordner | HTTP | HTTPS |
|--------|------|-------|
| `www/joomla/testseite/` | `http://testseite.joomla.test:80XX` | `https://testseite.joomla.test:84XX` |
| `www/wp/testseite/` | `http://testseite.wp.test:80XX` | `https://testseite.wp.test:84XX` |

**Ausnahme wp-multisite:** Kein Unterordner nötig – WordPress fängt Subdomains ab. In WP konfigurieren.

---

## BIND erforderlich für Domain-Mapping

Das automatische Mapping (`joomla.test`, `wp.test` etc.) funktioniert **nur mit aktiviertem BIND**:

```ini
USE_BIND=1   # in .env setzen
```

BIND startet einen lokalen DNS-Server, der `*.test` automatisch auflöst.

### Ohne BIND: manuell anpassen

**Windows:** `C:\Windows\System32\drivers\etc\hosts` - Alternativ die [PowerToys](https://learn.microsoft.com/de-de/windows/powertoys/) von Microsoft.  
**Linux/Mac OSX:** `/etc/hosts`

Die Dateien müssen als Administrator oder root bearbeitet werden.

```bash
# /etc/hosts (oder ~/.hosts auf Mac OSX)
127.0.0.1  joomla.test wp.test wpms.test subdomain.joomla.test
```

**Wichtig:** Wildcards (*.joomla.test) werden in der hosts-Datei nicht unterstützt, jede Sub/-Domain muss ausgeschrieben werden (subdomain.joomla.test).

---

## Netzwerkeinstellungen: DNS-Resolver

Damit das Domain-Mapping auch dann funktioniert, wenn der BIND-Container läuft, muss dein Betriebssystem **deinen Rechner als DNS-Resolver vor dem Router** verwenden. BIND hört lokal, alle `*.test` und `*.local` Anfragen werden beantwortet, alles andere an `DNS_FORWARDER` aus der `.env` durchgereicht. Dort kann z.B. die Router-IP hinterlegt werden.

### Linux mit NetworkManager / systemd-resolved

**TLD `.test` und `.local` abfangen :**  
(systemd-resolved ist der standard bei modernen Distributionen)
```bash
sudo mkdir -p /etc/systemd/resolved.conf.d

sudo tee /etc/systemd/resolved.conf.d/local-test-domains.conf > /dev/null <<EOF
[Resolve]
DNS=127.0.0.1:53
Domains=~test ~local
EOF
```

### Mac OSX mit mDNSResolver

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

Adapter-Optionen → IPv4 → Eigenschaften → DNS-Server:

- **Bevorzugter DNS:** 127.0.0.1
- **Alternativer DNS:** Router-IP

**Wichtig:** Ohne diesen Eintrag bleibt `*.test` und `*.local` unaufgelöst, da der Router die Domain nicht kennt. Der lokale BIND muss also **vor** dem Router stehen.

---

## Wichtige Befehle

| Aktion | Befehl |
|--------|--------|
| Server starten | `/opt/git/docker-lamp/docker-lamp start` |
| Server stoppen (Daten bleiben) | `/opt/git/docker-lamp/docker-lamp stop` |
| Server neustarten | `/opt/git/docker-lamp/docker-lamp restart` |
| Herunterfahren + DB-Sicherung | `/opt/git/docker-lamp/docker-lamp shutdown` |
| CLI in Container | `/opt/git/docker-lamp/docker-lamp cli php82` |
| CLI als Root | `/opt/git/docker-lamp/docker-lamp cli php82 -r` |
| Befehl ausführen | `/opt/git/docker-lamp/docker-lamp cli php82 -r 'apk add nodejs'` |
| Images aktualisieren | `/opt/git/docker-lamp/docker-lamp update-images` |
| Obsolete Images löschen | `/opt/git/docker-lamp/docker-lamp delete-obsolete-images` |

---

## Mehrere Kunden parallel betreiben

### Grundprinzip

Docker-lamp wird **einmal** in `/opt/git/docker-lamp` geklont. Für jeden Kunden legst du ein separates Projektverzeichnis an und kopierst die Struktur dorthin:

```bash
# Kunde1 (bereits erledigt)
mkdir -p ~/Projekte/Kunde1
cp -r /opt/git/docker-lamp/data/* ~/Projekte/Kunde1/
cp /opt/git/docker-lamp/.env-example ~/Projekte/Kunde1/.env

# Kunde2 anlegen
mkdir -p ~/Projekte/Kunde2
cp -r /opt/git/docker-lamp/data/* ~/Projekte/Kunde2/
cp /opt/git/docker-lamp/.env-example ~/Projekte/Kunde2/.env
```

### Struktur

```
/opt/git/docker-lamp/          # Tool (einmalig)
└── data/                      # Vorlage für Kundenprojekte

/home/user/Projekte/
├── Kunde1/                    # APP_BASEDIR Kunde1
│   ├── .env                   # Eigene Konfiguration
│   ├── ca/
│   ├── httpd/
│   ├── initDB/
│   ├── php/
│   └── www/
│       ├── joomla/
│       └── wp/
└── Kunde2/                    # APP_BASEDIR Kunde2
    ├── .env                   # Eigene Konfiguration
    ├── ca/
    ├── httpd/
    ├── initDB/
    ├── php/
    └── www/
        └── ...
```

### Konfiguration für Kunde1 und Kunde2

**~/Projekte/Kunde1/.env:**

```ini
APP_BASEDIR="$HOME/Projekte/Kunde1"
PHP_TO_USE="php74 php82"
MAP_PORT_80_443="php82"
DATABASE_TO_USE="mariadb118"
COMPOSE_PROJECT_NAME="kunde1-lamp"
USE_BIND=1
```

**~/Projekte/Kunde2/.env:**

```ini
APP_BASEDIR="$HOME/Projekte/Kunde2"
PHP_TO_USE="php82 php85"
MAP_PORT_80_443="php85"
DATABASE_TO_USE="mysql84"
COMPOSE_PROJECT_NAME="kunde2-lamp"
USE_BIND=1
```

### Wichtige Hinweise bei gleichzeitigem Betrieb

Wenn du mehrere Kunden gleichzeitig laufen lassen möchtest:

- **Nur ein BIND-Container** pro Rechner – in allen anderen Instanzen `USE_BIND=0` setzen.
- **PHP-Versionen, Datenbanken, phpMyAdmin, Mailcatcher** brauchen bei gleichzeitiger Nutzung eigene Ports – über die `.env` anpassbar.

**Empfehlung:** Für den Anfang immer nur eine Instanz parallel laufen lassen. Vor dem Wechsel zu einem anderen Kunden die aktuelle Instanz beenden (`/opt/git/docker-lamp/docker-lamp shutdown`).

---

## Das Konzept von `APP_BASEDIR`

`APP_BASEDIR` ist das **Arbeitsverzeichnis** jeder LAMP-Instanz. Dort liegen alle Daten, Konfigurationen und Webseiten – vollständig unabhängig vom Installationsort des `docker-lamp`-Skripts.

### Warum macht man das?

1. **Tool und Projekt getrennt:** Docker-lamp liegt zentral in `/opt/git/docker-lamp`, deine Kundenprojekte in `~/Projekte/...`
2. **Git-freundlich:** Du versionierst nur `APP_BASEDIR` (dein Kundenprojekt), nicht das gesamte docker-lamp-Repo.
3. **Kunden-Trennung:** Jeder Kunde bekommt sein eigenes Verzeichnis mit eigener `.env`, eigenen Datenbanken und eigenem SSL-Zertifikaten.
4. **Keine Konflikte:** Verschiedene Kunden können unterschiedliche PHP-Versionen, Datenbank-Versionen und Ports nutzen.

---

## Häufige Probleme

### `ERROR: for kunde2-lamp_bind Cannot start service bind`
Port-Konflikt mit bestehendem DNS.  
**Lösung:** BIND deaktivieren:
```ini
USE_BIND=0
```
oder auf eine feste IP binden:
```ini
DNS_A="*.local=<IP des Rechners z.B. 192.168.0.100>,*.test=192.168.0.100"
```

### Zertifikate werden abgelehnt
Minica Root CA importieren:
1. Datei: `$APP_BASEDIR/ca/minica-root-ca.pem`
2. Firefox: Einstellungen → Datenschutz & Sicherheit → Zertifikate → Importieren
3. Chrome/Chromium: Einstellungen → Sicherheit → Vertrauenswürdige Stammzertifizierungsstellen

**Empfehlung:** Damit bei mehreren Kunden nicht mehrere Zertifikate importiert werden müssen die Dateien `$APP_BASEDIR/ca/minica-root-ca.pem` und `$APP_BASEDIR/ca/minica-root-ca-key.pem` in den jeweiligen Kundenordner kopieren. Die Zertifikate werden dann beim Hochfahren des Projekts automatisch mit dem gleichen Schlüssel signiert.
