-include .env
export

.PHONY: help psql seed-lab01 run-lab01

help:
	@echo "Available commands:"
	@echo "  make psql         - Connect to Neon database using psql"
	@echo "  make seed-lab01   - Seed TechnoMart database for Lab 01"
	@echo "  make run-lab01    - Execute Level 1 queries for Lab 01"

psql:
	@psql "$$DATABASE_URL"

seed-lab01:
	@psql "$$DATABASE_URL" -f lab01/task/technomart.sql

run-lab01:
	@psql "$$DATABASE_URL" -f lab01/sql/01_level_1.sql
