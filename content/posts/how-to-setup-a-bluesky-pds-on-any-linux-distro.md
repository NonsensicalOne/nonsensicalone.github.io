+++
date = '2025-06-22T20:35:27Z'
draft = false
title = 'How to Setup a Bluesky PDS on Any Linux Distro'
+++

Want to setup a Bluesky PDS (Personal Data Server) but frustrated that the [official installer script](https://raw.githubusercontent.com/bluesky-social/pds/main/installer.sh) only supports Debian and Ubuntu? This guide will walk you through setting up a Bluesky PDS on any Linux distribution by manually following the same steps the installer performs.

## Prerequisites

You'll need:
- A Linux server with root access
- A domain name you control
- Basic command line knowledge
- At least 2GB RAM and 20GB storage

## Step 1: Install Required Packages

The exact package names vary by distribution, but you'll need these packages for PDS:

**System packages:**
```
ca-certificates
curl
gnupg
jq
lsb-release (or equivalent)
openssl
sqlite3
xxd
```

**Docker packages:**
```
containerd.io
docker-ce
docker-ce-cli
docker-compose-plugin
```

### Distribution-specific examples:

**CentOS/RHEL/Fedora:**
```bash
# Install Docker first
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install ca-certificates curl gnupg jq openssl sqlite xxd docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

**Alpine Linux:**
```bash
sudo apk add ca-certificates curl gnupg jq openssl sqlite xxd docker docker-compose
```

## Step 2: Configure DNS Records

Create DNS records for your domain. Replace `example.com` with your actual domain and `YOUR_SERVER_IP` with your server's public IP:

```
example.com         A      YOUR_SERVER_IP
*.example.com       A      YOUR_SERVER_IP
```

**Important:** Wait 3-5 minutes after creating DNS records before proceeding to allow for DNS propagation.

## Step 3: Configure Docker

Start and enable the Docker service:
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

For non-systemd distros:
```bash
doas rc-update add docker default
doas service docker start
```

Create or edit `/etc/docker/daemon.json` to prevent Docker from dicking with logs (haha unfunny joke):

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "500m",
    "max-file": "4"
  }
}
```

Restart Docker (obv)
```bash
sudo systemctl restart docker
```

For non-systemd distros:
```bash
doas rc-service docker restart
```

## Step 4: Create Directory Structure

Create the PDS data directory with secure permissions:
```bash
sudo mkdir -p /pds
sudo chmod 700 /pds
```

Create Caddy directories:
```bash
sudo mkdir -p /pds/caddy/data
sudo mkdir -p /pds/caddy/etc/caddy
```

## Step 5: Configure Caddy (Reverse Proxy)

Create the Caddyfile at `/pds/caddy/etc/caddy/Caddyfile`:

```
{
	email YOUR_EMAIL_HERE
	on_demand_tls {
		ask http://localhost:3000/tls-check
	}
}

*.YOUR_DOMAIN_HERE, YOUR_DOMAIN_HERE {
	tls {
		on_demand
	}
	reverse_proxy http://localhost:3000
}
```

Make sure to replace `YOUR_EMAIL_HERE` with your email and `YOUR_DOMAIN_HERE` with your domain.

## Step 6: Generate PDS Configuration

Create the PDS environment file at `/pds/pds.env`. You'll need to generate secure secrets:

```bash
# Generate secrets
JWT_SECRET=$(openssl rand -hex 16)
ADMIN_PASSWORD=$(openssl rand -hex 16)
PLC_KEY=$(openssl ecparam -name secp256k1 -genkey -noout -outform DER | tail -c +8 | head -c 32 | xxd -p -c 32)

# Create the config file (you might want to replace sudo with doas)
sudo tee /pds/pds.env > /dev/null <<EOF
PDS_HOSTNAME=YOUR_DOMAIN_HERE
PDS_JWT_SECRET=${JWT_SECRET}
PDS_ADMIN_PASSWORD=${ADMIN_PASSWORD}
PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX=${PLC_KEY}
PDS_DATA_DIRECTORY=/pds
PDS_BLOBSTORE_DISK_LOCATION=/pds/blocks
PDS_BLOB_UPLOAD_LIMIT=52428800
PDS_DID_PLC_URL=https://plc.directory
PDS_BSKY_APP_VIEW_URL=https://api.bsky.app
PDS_BSKY_APP_VIEW_DID=did:web:api.bsky.app
PDS_REPORT_SERVICE_URL=https://mod.bsky.app
PDS_REPORT_SERVICE_DID=did:plc:ar7c4by46qjdydhdevvrndac
PDS_CRAWLERS=https://bsky.network
LOG_ENABLED=true
EOF
```

**Important:** Save the `ADMIN_PASSWORD` value - because no one wants to be locked out of their PDS!

## Step 7: Download Docker Compose Configuration

Download the official PDS compose file:
```bash
sudo curl -o /pds/compose.yaml https://raw.githubusercontent.com/bluesky-social/pds/main/compose.yaml
```

The compose file assumes `/pds` as the data directory, so no modifications are needed.

## Step 8: Create System Service

### For systemd (Most modern distributions)

Create a systemd service file at `/etc/systemd/system/pds.service`:

```ini
[Unit]
Description=Bluesky PDS Service
Documentation=https://github.com/bluesky-social/pds
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/pds
ExecStart=/usr/bin/docker compose --file /pds/compose.yaml up --detach
ExecStop=/usr/bin/docker compose --file /pds/compose.yaml down

[Install]
WantedBy=default.target
```

Enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable pds
sudo systemctl start pds
```

### For OpenRC (Alpine Linux, etc.)

Create an OpenRC service file at `/etc/init.d/pds`:

```bash
#!/sbin/openrc-run

name="pds"
description="Bluesky PDS Service"
command="/usr/bin/docker"
command_args="compose --file /pds/compose.yaml up --detach"
command_background="no"
pidfile="/run/${RC_SVCNAME}.pid"
directory="/pds"

depend() {
    need docker
    after docker
}

start_pre() {
    checkpath --directory --owner root:root --mode 0755 /run
}

start() {
    ebegin "Starting ${name}"
    start-stop-daemon --start \
        --chdir "${directory}" \
        --exec "${command}" \
        --pidfile "${pidfile}" \
        --make-pidfile \
        --background \
        -- ${command_args}
    eend $?
}

stop() {
    ebegin "Stopping ${name}"
    /usr/bin/docker compose --file /pds/compose.yaml down
    start-stop-daemon --stop --pidfile "${pidfile}"
    eend $?
}

restart() {
    stop
    start
}
```

Make the script executable and enable the service:
```bash
sudo chmod +x /etc/init.d/pds
sudo rc-update add pds default
sudo rc-service pds start
```

## Step 9: Configure Firewall

Open the required ports (80 for HTTP, 443 for HTTPS):

**UFW (Ubuntu/Debian):**
```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

**firewalld (CentOS/RHEL/Fedora):**
```bash
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
```

**iptables:**
```bash
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```

## Step 10: Install PDS Admin Tool

Download the PDS administration tool:
```bash
sudo curl -o /usr/local/bin/pdsadmin https://raw.githubusercontent.com/bluesky-social/pds/main/pdsadmin.sh
sudo chmod +x /usr/local/bin/pdsadmin
```

## Step 11: Verify Installation

Check that everything is running:
```bash
sudo systemctl status pds
sudo docker logs pds
```

You should see the PDS container running and logs indicating successful startup.

## Step 12: Create Your First Account

Use the pdsadmin tool to create your first account:
```bash
sudo pdsadmin account create
```

Follow the prompts to create your account.

## Management Commands

Here are some useful commands for managing your PDS:

### For systemd systems:
- **Check service status:** `sudo systemctl status pds`
- **Start service:** `sudo systemctl start pds`
- **Stop service:** `sudo systemctl stop pds`
- **Restart service:** `sudo systemctl restart pds`
- **Enable on boot:** `sudo systemctl enable pds`
- **View logs:** `sudo docker logs -f pds`

### For OpenRC systems:
- **Check service status:** `sudo rc-service pds status`
- **Start service:** `sudo rc-service pds start`
- **Stop service:** `sudo rc-service pds stop`
- **Restart service:** `sudo rc-service pds restart`
- **Enable on boot:** `sudo rc-update add pds default`
- **View logs:** `sudo docker logs -f pds`

### PDS-specific commands:
- **Create account:** `sudo pdsadmin account create`
- **List accounts:** `sudo pdsadmin account list`
- **Help:** `sudo pdsadmin help`

## Troubleshooting

**Service won't start:**
- Check Docker is running: 
  - systemd: `sudo systemctl status docker`
  - OpenRC: `sudo rc-service docker status`
- Verify DNS records are propagated: `nslookup your-domain.com`
- Check firewall rules are applied

**SSL certificate issues:**
- Ensure ports 80 and 443 are open
- Verify DNS records point to correct IP
- Check Caddy logs: `sudo docker logs caddy`

**Can't create accounts:**
- Verify the PDS service is running
- Check the admin password in `/pds/pds.env`

## Backup Your PDS

Your PDS data is stored in `/pds`. To backup:
```bash
sudo tar -czf pds-backup-$(date +%Y%m%d).tar.gz /pds
```

## Conclusion

You now have a fully functional Bluesky PDS running on your Linux distribution of choice! Your PDS will automatically handle SSL certificates, user management, and federation with the broader Bluesky network.

Remember to keep your system updated and monitor the logs regularly. The Bluesky PDS is still evolving, so check the [official repository](https://github.com/bluesky-social/pds) for updates and announcements.