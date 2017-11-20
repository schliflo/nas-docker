#############################
# ENVIRONMENT
#############################

export COMPOSE_PROJECT_NAME=nas-docker

#############################
# PROJECT STATES
#############################
up:
	docker-compose up -d

stop:
	docker-compose stop

update:
	docker-compose pull
	docker-compose build --pull
	make up

#############################
# BACKUP/RESTORE
#############################
nextcloud-db-backup:
	mkdir -p apps/duplicati/local/nextcloud
	docker exec -i $$(docker-compose ps -q nextcloud-db) mysqldump -u root -p$NEXTCLOUD_MYSQL_ROOT_PASSWORD --opt --single-transaction --events --routines --comments --all-databases | bzip2 > "apps/duplicati/local/nextcloud/dump.sql.bz2"

nextcloud-db-restore:
	bzcat "apps/duplicati/local/nextcloud/dump.sql.bz2" | docker exec -i $$(docker-compose ps -q nextcloud-db) mysql -u root -p$NEXTCLOUD_MYSQL_ROOT_PASSWORD
	echo "FLUSH PRIVILEGES;" | docker exec -i $$(docker-compose ps -q nextcloud-db) mysql -u root -p$NEXTCLOUD_MYSQL_ROOT_PASSWORD
