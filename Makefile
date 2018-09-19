ARGS = $(filter-out $@,$(MAKECMDGOALS))

#############################
# ENVIRONMENT
#############################

export COMPOSE_PROJECT_NAME=nas-docker
export BACKUP_DIR=backup

#############################
# PROJECT STATES
#############################
up:
	docker-compose up -d --remove-orphans

stop:
	docker-compose stop

logs:
	docker-compose logs -f --tail=42 $(ARGS)

#############################
# CONTAINER ACCESS
#############################

ssh:
	docker exec -it -u root $$(docker-compose ps -q $(ARGS)) sh

#############################
# UTILITIES
#############################

update:
	docker-compose pull
	docker-compose build --pull
	make nextcloud-maintenance-on
	make up
	make nextcloud-maintenance-off
	make nextcloud-upgrade
	make nextcloud-maintenance-off

nextcloud-occ:
	docker exec -ti -u www-data nextcloud-app php -d memory_limit=4096M /var/www/html/occ $(ARGS)

nextcloud-upgrade:
	docker exec -u www-data nextcloud-app php -d memory_limit=4096M /var/www/html/occ upgrade
	docker exec -u www-data nextcloud-app php -d memory_limit=4096M /var/www/html/occ db:add-missing-indices

nextcloud-maintenance-off:
	docker exec -u www-data nextcloud-app php -d memory_limit=4096M /var/www/html/occ maintenance:mode --off

nextcloud-maintenance-on:
	docker exec -u www-data nextcloud-app php -d memory_limit=4096M /var/www/html/occ maintenance:mode --on

#############################
# BACKUP/RESTORE
#############################
backup-dbs: nextcloud-db-backup gitea-db-backup hackmd-db-backup

nextcloud-db-backup:
	docker exec $$(docker-compose ps -q nextcloud-db) mysqldump -uroot -p${NEXTCLOUD_MYSQL_ROOT_PASSWORD} --opt --single-transaction --events --all-databases --routines --comments | bzip2 > "${BACKUP_DIR}/nextcloud-db.sql.bz2"

nextcloud-db-restore:
	make nextcloud-maintenance-on
	bzcat "${BACKUP_DIR}/nextcloud-db.sql.bz2" | docker exec -i $$(docker-compose ps -q nextcloud-db) mysql -u root -p${NEXTCLOUD_MYSQL_ROOT_PASSWORD}
	echo "FLUSH PRIVILEGES;" | docker exec -i $$(docker-compose ps -q nextcloud-db) mysql -u root -p${NEXTCLOUD_MYSQL_ROOT_PASSWORD}
	make nextcloud-maintenance-off
	make nextcloud-upgrade
	make nextcloud-maintenance-off

gitea-db-backup:
	docker exec $$(docker-compose ps -q gitea-db) mysqldump -uroot -p${GITEA_MYSQL_ROOT_PASSWORD} --opt --single-transaction --events --all-databases --routines --comments | bzip2 > "${BACKUP_DIR}/gitea-db.sql.bz2"

gitea-db-restore:
	bzcat "${BACKUP_DIR}/nextcloud-db.sql.bz2" | docker exec -i $$(docker-compose ps -q gitea-db) mysql -u root -p${GITEA_MYSQL_ROOT_PASSWORD}
	echo "FLUSH PRIVILEGES;" | docker exec -i $$(docker-compose ps -q gitea-db) mysql -u root -p${GITEA_MYSQL_ROOT_PASSWORD}

hackmd-db-backup:
	docker exec $$(docker-compose ps -q hackmd-db) pg_dumpall -c -U hackmd | bzip2 > "${BACKUP_DIR}/hackmd-db.sql.bz2"

hackmd-db-restore:
	bzcat "${BACKUP_DIR}/hackmd-db.sql.bz2" | docker exec -i $$(docker-compose ps -q hackmd-db) psql -U hackmd
