# NAS docker
docker-compose setup for my nas/homeserver including a [plex](https://www.plex.tv/), [nextcloud](https://nextcloud.com/) and [home-assistant](https://home-assistant.io/) instances.

## Environment
You need to have the following environment variables setup or replaced in your `docker-compose.yml` and your storage mounted in `/mnt/storage/cloud` and `/mnt/storage/shares` for nextcloud and plex respectively.

example `/etc/environment`
```
DOCKER_USER_ID=1002
DOCKER_USER_GROUP_ID=1002

TIMEZONE=Europe/Berlin

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

## Shares
As i wanted to have certain directories directly accessible in my network, i created a user `shareuser`, which owns the shared dir and used the following config for `/etc/samba/smb.conf`:
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
