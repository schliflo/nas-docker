up:
	docker-compose -f docker-compose.yml up -d

stop:
	docker-compose -f docker-compose.yml stop -d

update:
	docker-compose pull
	docker-compose build
	docker-com
