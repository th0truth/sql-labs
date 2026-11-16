.PHONY: help web seed all run-lab07-web seed-lab07 run-lab07-all

help:
	@echo "Lab 07 commands:"
	@echo "  make web            - Start Express web server (http://localhost:3000)"
	@echo "  make seed           - Seed database (validation, indexes, 50 posts)"
	@echo "  make all            - Run all database scripts"
	@echo "  make run-lab07-web  - Alias for 'make web'"

web run-lab07-web:
	@cd web_app && node server.js

seed seed-lab07:
	@chmod +x database/run_all.sh && ./database/run_all.sh

all run-lab07-all: seed
