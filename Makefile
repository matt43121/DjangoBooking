compose := /usr/bin/python3 tools/jinja-compose.py --template docker-compose.yml.jinja
compose_file := docker-compose -f jinja-compose.yml

build: down
	PRODUCTION="false" $(compose) build

dev: build
	PRODUCTION="false" $(compose) up -d

down:
	PRODUCTION="false" $(compose) down --volumes

prod_build: prod_down
	PRODUCTION="true" $(compose) build

prod: prod_build
	PRODUCTION="true" $(compose) up -d

prod_down:
	PRODUCTION="true" $(compose) down --volumes

shell-nginx:
	docker exec -ti nginx /bin/sh

shell-web:
	docker exec -ti django /bin/sh

shell-db:
	docker exec -ti postgres /bin/sh -c "psql --username=django_admin --dbname=django_db"

log-nginx:
	$(compose) logs --follow nginx

log-web:
	$(compose) logs --follow web

log-db:
	$(compose) logs --follow db


npm_install:
	npm --prefix src/base/_static install
	npm --prefix src/booking/_static install

build_webpack:
	npm --prefix src/base/_static run build
	npm --prefix src/booking/_static run build

collectstatic: build_webpack
	docker exec django /bin/sh -c "python manage.py collectstatic --noinput --clear"

runtests:
	make build
	make up
	docker exec django /bin/sh -c "python manage.py test --keepdb"
	make stop

test:
	docker exec django /bin/sh -c "python manage.py test --keepdb"