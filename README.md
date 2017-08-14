# nas-docker
docker-compose setup for my nas/homeserver including a [plex](https://www.plex.tv/) and a [nextcloud](https://nextcloud.com/) instance

## environment
You need to have the following environment variables setup or replaced in your `docker-compose.yml` and your storage mounted in `/mnt/storage/cloud` and `/mnt/storage/shares` for nextcloud and plex respectively.

example `/etc/environment`
```
DOCKER_USER_ID=1002
DOCKER_USER_GROUP_ID=1002

LETSENCRYPT_EMAIL=le@example.com

PLEX_HOSTNAME=nas
PLEX_TIMEZONE=Europe/Berlin
PLEX_ADVERTISE_IP=http://<IP of your nas here>:32400/
PLEX_VIRTUAL_HOST=plex.example.com

NEXTCLOUD_VIRTUAL_HOST=cloud.example.com
NEXTCLOUD_MYSQL_ROOT_PASSWORD=yourRootPasswordHere
NEXTCLOUD_MYSQL_PASSWORD=yourPasswordHere
```
(you need to have correct DNS records set for the domains you want to use and probably setup port forwarding of ports 80 and 443 to your nas in order to get remote access and let's encrypt working)