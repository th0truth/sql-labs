-include .env
export

.PHONY: help psql seed-lab01 run-lab01 run-lab01-level2 run-lab01-level3 run-lab01-all \
        run-lab02 run-lab02-level2 run-lab02-level3 run-lab02-all \
        run-lab03 run-lab03-level2 run-lab03-level3 run-lab03-all \
        seed-lab04 run-lab04-console run-lab04-web docker-lab04-up docker-lab04-down \
        seed-lab05 benchmark-lab05 maintain-lab05 backup-lab05 run-lab05-all \
        mongo-up mongo-down run-lab06-all run-all

help:
	@echo "Available commands:"
	@echo "  make psql              - Connect to Neon database using psql"
	@echo "  make seed-lab01        - Seed TechnoMart database for Lab 01"
	@echo "  make run-lab01         - Execute Level 1 queries for Lab 01"
	@echo "  make run-lab01-level2  - Execute Level 2 queries for Lab 01"
	@echo "  make run-lab01-level3  - Execute Level 3 queries for Lab 01"
	@echo "  make run-lab01-all     - Execute all Lab 01 levels sequentially"
	@echo "  make run-lab02         - Execute Level 1 queries for Lab 02"
	@echo "  make run-lab02-level2  - Execute Level 2 queries for Lab 02"
	@echo "  make run-lab02-level3  - Execute Level 3 queries for Lab 02"
	@echo "  make run-lab02-all     - Execute all Lab 02 levels sequentially"
	@echo "  make run-lab03         - Execute Level 1 queries for Lab 03"
	@echo "  make run-lab03-level2  - Execute Level 2 queries for Lab 03"
	@echo "  make run-lab03-level3  - Execute Level 3 queries for Lab 03"
	@echo "  make run-lab03-all     - Execute all Lab 03 levels sequentially"
	@echo "  make seed-lab04        - Seed Bookstore schema for Lab 04 (DDL, Data, SP, Triggers, Views)"
	@echo "  make run-lab04-console - Run Lab 04 Console CRUD application"
	@echo "  make run-lab04-web     - Run Lab 04 Flask Web application"
	@echo "  make docker-lab04-up   - Start Lab 04 Docker Compose stack (PostgreSQL + pgAdmin + Web)"
	@echo "  make docker-lab04-down - Stop Lab 04 Docker Compose stack"
	@echo "  make seed-lab05        - Seed and optimize Lab 05 database (Schema, 205k+ rows, Indexes, Triggers, Views, Roles)"
	@echo "  make benchmark-lab05   - Run EXPLAIN ANALYZE benchmarks Before and After optimization"
	@echo "  make maintain-lab05    - Run automated maintenance procedure and performance monitoring"
	@echo "  make backup-lab05      - Test logical backup (pg_dump) and restoration"
	@echo "  make run-lab05-all     - Execute full Lab 05 workflow sequentially"
	@echo "  make mongo-up          - Start MongoDB 8.0 Docker container"
	@echo "  make mongo-down        - Stop MongoDB Docker container"
	@echo "  make run-lab06-all     - Execute full Lab 06 MongoDB workflow (CRUD, Indexes, Aggregation, Level 3)"
	@echo "  make run-all           - Execute all labs sequentially"

psql:
	@psql "$$DATABASE_URL"

seed-lab01:
	@psql "$$DATABASE_URL" -f lab01/task/technomart.sql

run-lab01:
	@psql "$$DATABASE_URL" -f lab01/sql/01_level_1.sql

run-lab01-level2:
	@psql "$$DATABASE_URL" -f lab01/sql/02_level_2.sql

run-lab01-level3:
	@psql "$$DATABASE_URL" -f lab01/sql/03_level_3.sql

run-lab01-all: run-lab01 run-lab01-level2 run-lab01-level3

run-lab02:
	@psql "$$DATABASE_URL" -f lab02/sql/01_level_1.sql

run-lab02-level2:
	@psql "$$DATABASE_URL" -f lab02/sql/02_level_2.sql

run-lab02-level3:
	@psql "$$DATABASE_URL" -f lab02/sql/03_level_3.sql

run-lab02-all: run-lab02 run-lab02-level2 run-lab02-level3

run-lab03:
	@psql "$$DATABASE_URL" -f lab03/sql/01_level_1.sql

run-lab03-level2:
	@psql "$$DATABASE_URL" -f lab03/sql/02_level_2.sql

run-lab03-level3:
	@psql "$$DATABASE_URL" -f lab03/sql/03_level_3.sql

run-lab03-all: run-lab03 run-lab03-level2 run-lab03-level3

seed-lab04:
	@psql "$$DATABASE_URL" -f lab04/database/01_create_tables.sql
	@psql "$$DATABASE_URL" -f lab04/database/02_insert_data.sql
	@psql "$$DATABASE_URL" -f lab04/database/03_create_procedures.sql
	@psql "$$DATABASE_URL" -f lab04/database/04_create_triggers.sql
	@psql "$$DATABASE_URL" -f lab04/database/05_create_views.sql

run-lab04-console:
	@cd lab04/console_app && uv run --with psycopg2-binary --with python-dotenv python main.py

run-lab04-web:
	@cd lab04/web_app && uv run python run.py

docker-lab04-up:
	@docker compose -f lab04/docker-compose.yaml up -d

docker-lab04-down:
	@docker compose -f lab04/docker-compose.yaml down -v

seed-lab05:
	@psql "$$DATABASE_URL" -f lab05/sql/01_create_schema.sql
	@psql "$$DATABASE_URL" -f lab05/sql/02_seed_large_dataset.sql
	@psql "$$DATABASE_URL" -f lab05/sql/04_create_indexes.sql
	@psql "$$DATABASE_URL" -f lab05/sql/06_views_and_rules.sql
	@psql "$$DATABASE_URL" -f lab05/sql/07_triggers_and_automation.sql
	@psql "$$DATABASE_URL" -f lab05/sql/08_roles_and_permissions.sql

benchmark-lab05:
	@psql "$$DATABASE_URL" -f lab05/sql/03_explain_before.sql
	@psql "$$DATABASE_URL" -f lab05/sql/05_explain_after.sql

maintain-lab05:
	@psql "$$DATABASE_URL" -f lab05/sql/09_maintenance_and_monitoring.sql

backup-lab05:
	@chmod +x lab05/sql/10_backup_restore.sh && ./lab05/sql/10_backup_restore.sh

run-lab05-all: seed-lab05 benchmark-lab05 maintain-lab05 backup-lab05

mongo-up:
	@if ! docker ps --format '{{.Names}}' | grep -q "^mongodb$$"; then \
		docker rm -f mongodb 2>/dev/null || true; \
		docker run -d --name mongodb --net=host mongo:8.0; \
		echo "MongoDB 8.0 container started."; \
	else \
		echo "MongoDB container is already running."; \
	fi

mongo-down:
	@docker rm -f mongodb 2>/dev/null || true
	@echo "MongoDB container stopped."

run-lab06-all:
	@chmod +x lab06/scripts/run_all.sh && ./lab06/scripts/run_all.sh

run-all: run-lab01-all run-lab02-all run-lab03-all seed-lab04 seed-lab05 run-lab06-all
