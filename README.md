# NAS docker
Repository containing the docker-compose setup for my NAS / homeserver

## Features:
- [Nextcloud](https://nextcloud.com/) for convenient cloud storage
- [Home Assistant](https://home-assistant.io/) for home automation and control
- [Plex](https://www.plex.tv/) for movies and shows
- [Duplicati](https://github.com/linuxserver/docker-duplicati) for backups
- [Nginx Proxy](https://github.com/jwilder/nginx-proxy) with [Let's Encrypt](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) for secure external access

## Environment
You need to have the following environment variables setup or replaced in your `docker-compose.yml` and your storage mounted in `/mnt/storage/cloud` and `/mnt/storage/shares` for nextcloud and plex respectively.

example `/etc/environment`
```
DOCKER_USER_ID=1002
DOCKER_USER_GROUP_ID=1002

TIMEZONE=Europe/Berlin

STORAGE_PATH=/mnt/storage

LETSENCRYPT_EMAIL=le@example.com

PLEX_HOSTNAME=nas
PLEX_ADVERTISE_IP=http://<IP of your nas here>:32400/
PLEX_VIRTUAL_HOST=plex.example.com

NEXTCLOUD_VIRTUAL_HOST=cloud.example.com
NEXTCLOUD_MYSQL_ROOT_PASSWORD=yourRootPasswordHere
NEXTCLOUD_MYSQL_PASSWORD=yourPasswordHere

HOME_ASSISTANT_VIRTUAL_HOST=hass.example.com
```
(you need to have correct DNS records set for the domains you want to use and probably setup port forwarding of ports 80 and 443 to your nas in order to get remote access and let's encrypt working)

## Setup
1. Make sure to have `docker` and `docker-compose` installed on your system.
1. You also need to have some sort of dynamic DNS setup to your (public) IP. Point the Domain(s) you are using to this IP.
1. Add a static rule to your router for the system you are running this on, so the (private) IP doesn't change. Then forward ports `80` and `443 to this IP
1. Clone the repo to `/opt`
1. Run `docker-compose -f /opt/docker-compose.yml up -d`
1. Services should be available at the hosts specified in your environment. 

## Shares
As I wanted to have certain directories directly accessible in my network, I created a user `shareuser`, which owns the shared dir and used the following config for `/etc/samba/smb.conf`:
```
[global]
  workgroup = WORKGROUP
  server string = nas
  security = user
  guest ok = yes
  map to guest = Bad Password

  log file = /var/log/samba/%m.log
  max log size = 50
  printcap name = /dev/null
  load printers = no

# Samba Shares
[nas]
  comment = Storage on NAS
  path = /mnt/storage/shares
  browseable = yes
  public = yes
  writeable = yes
  create mask = 0644
  directory mask = 0755
  force user = shareuser
```
*You will need to restart samba for config changes to take effect*
