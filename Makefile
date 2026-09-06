-include .env
export

.PHONY: help psql seed-lab01 run-lab01 run-lab01-level2 run-lab01-level3 run-all

help:
	@echo "Available commands:"
	@echo "  make psql              - Connect to Neon database using psql"
	@echo "  make seed-lab01        - Seed TechnoMart database for Lab 01"
	@echo "  make run-lab01         - Execute Level 1 queries for Lab 01"
	@echo "  make run-lab01-level2  - Execute Level 2 queries for Lab 01"
	@echo "  make run-lab01-level3  - Execute Level 3 queries for Lab 01"
	@echo "  make run-all           - Execute all levels (1, 2, 3) sequentially"

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

run-all: run-lab01 run-lab01-level2 run-lab01-level3
