-include .env
export

.PHONY: help psql seed-lab01 run-lab01 run-lab01-level2 run-lab01-level3 run-lab01-all \
        run-lab02 run-lab02-level2 run-lab02-level3 run-lab02-all \
        run-lab03 run-lab03-level2 run-lab03-level3 run-lab03-all run-all

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

run-all: run-lab01-all run-lab02-all run-lab03-all
