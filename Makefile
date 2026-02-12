# Makefile (final) for game-project416

SHELL := /bin/bash

COMPOSE     := docker compose
SERVICE     := app
APP_ROOT    := /app
FLUTTER_DIR := my_app

PORT        ?= 8081
HOST        ?= 0.0.0.0
EMULATORS   ?= firestore,auth,functions

# ✅ デフォルトはホーム（他ゲームと共存）
FLUTTER_TARGET ?= lib/main.dart

.PHONY: help
help:
	@echo ""
	@echo "game-project416 Makefile targets"
	@echo ""
	@echo "[Docker]"
	@echo "  make up              Build & start containers (detached)"
	@echo "  make down            Stop & remove containers (keep volumes)"
	@echo "  make down-v          Stop & remove containers and volumes (DANGER)"
	@echo "  make restart         Restart containers"
	@echo "  make ps              Show container status"
	@echo "  make logs            Follow logs (all)"
	@echo "  make logs-app        Follow logs (app)"
	@echo "  make shell           Open bash in app container"
	@echo ""
	@echo "[Flutter (in container)]"
	@echo "  make flutter-get     flutter pub get"
	@echo "  make lint            flutter analyze"
	@echo "  make test            flutter test"
	@echo "  make flutter-web     flutter run web-server on $(HOST):$(PORT) (target=$(FLUTTER_TARGET))"
	@echo "  make flutter-web-horse  flutter run horse_race/dev_main.dart (escape hatch)"
	@echo ""
	@echo "[Firebase (in container)]"
	@echo "  make firebase-login  firebase login --no-localhost"
	@echo "  make emulators       firebase emulators:start --only $(EMULATORS)"
	@echo ""
	@echo "[Project checks]"
	@echo "  make status          Quick health check (ps + versions)"
	@echo ""
	@echo "Examples:"
	@echo "  make up && make status"
	@echo "  make flutter-web"
	@echo "  make flutter-web FLUTTER_TARGET=lib/main.dart"
	@echo "  make flutter-web-horse"
	@echo "  make emulators EMULATORS=firestore,auth"
	@echo ""

# ---- Guards ----
.PHONY: _guard_root
_guard_root:
	@if [ ! -f docker-compose.yml ]; then \
		echo "ERROR: docker-compose.yml not found. Run this from repository root."; \
		exit 1; \
	fi

# ✅ 非常駐コマンド用（TTY不要でOK）
define exec_app
	$(COMPOSE) exec -T $(SERVICE) bash -lc "$(1)"
endef

# ✅ 常駐コマンド用（flutter run / emulators はTTYあり。Ctrl+Cで止められる）
define exec_app_tty
	$(COMPOSE) exec $(SERVICE) bash -lc "$(1)"
endef

# ---- Docker ----
.PHONY: up
up: _guard_root
	$(COMPOSE) up -d --build
	@$(MAKE) ps

.PHONY: down
down: _guard_root
	$(COMPOSE) down

.PHONY: down-v
down-v: _guard_root
	@echo "WARNING: This removes volumes and may delete persisted data."
	$(COMPOSE) down -v

.PHONY: restart
restart: _guard_root
	$(COMPOSE) restart
	@$(MAKE) ps

.PHONY: ps
ps: _guard_root
	$(COMPOSE) ps

.PHONY: logs
logs: _guard_root
	$(COMPOSE) logs -f --tail=200

.PHONY: logs-app
logs-app: _guard_root
	$(COMPOSE) logs -f --tail=200 $(SERVICE)

.PHONY: shell
shell: _guard_root
	$(COMPOSE) exec $(SERVICE) bash

# ---- Flutter ----
.PHONY: flutter-get
flutter-get: _guard_root
	$(call exec_app,cd $(APP_ROOT)/$(FLUTTER_DIR) && flutter pub get)

.PHONY: lint
lint: _guard_root
	$(call exec_app,cd $(APP_ROOT)/$(FLUTTER_DIR) && flutter analyze)

.PHONY: test
test: _guard_root
	$(call exec_app,cd $(APP_ROOT)/$(FLUTTER_DIR) && flutter test)

# ✅ デフォルトはホーム（lib/main.dart）を起動
.PHONY: flutter-web
flutter-web: _guard_root
	@echo "Flutter web-server: http://localhost:$(PORT)"
	@echo "Target: $(FLUTTER_TARGET)"
	@echo "Stop with Ctrl+C"
	$(call exec_app_tty,cd $(APP_ROOT)/$(FLUTTER_DIR) && flutter pub get && flutter run -d web-server --web-hostname $(HOST) --web-port $(PORT) -t $(FLUTTER_TARGET))

# ✅ 競馬だけ単体起動したいときの逃げ道（残す）
.PHONY: flutter-web-horse
flutter-web-horse: _guard_root
	@echo "Flutter web-server: http://localhost:$(PORT)"
	@echo "Target: lib/horse_race/dev_main.dart"
	@echo "Stop with Ctrl+C"
	$(call exec_app_tty,cd $(APP_ROOT)/$(FLUTTER_DIR) && flutter pub get && flutter run -d web-server --web-hostname $(HOST) --web-port $(PORT) -t lib/horse_race/dev_main.dart)

# ---- Firebase ----
.PHONY: firebase-login
firebase-login: _guard_root
	@echo "Firebase login: follow the printed URL and paste code in terminal."
	$(call exec_app_tty,cd $(APP_ROOT)/$(FLUTTER_DIR) && firebase login --no-localhost)

.PHONY: emulators
emulators: _guard_root
	@echo "Starting Firebase emulators: $(EMULATORS)"
	@echo "Stop with Ctrl+C"
	$(call exec_app_tty,cd $(APP_ROOT) && firebase emulators:start --only $(EMULATORS))

# ---- Project checks ----
.PHONY: status
status: _guard_root
	@$(MAKE) ps
	@echo ""
	@echo "[Versions]"
	@$(COMPOSE) exec -T $(SERVICE) bash -lc "flutter --version | head -n 1"
	@$(COMPOSE) exec -T $(SERVICE) bash -lc "firebase --version || true"
	@$(COMPOSE) exec -T $(SERVICE) bash -lc "node -v || true"
	@echo ""
	@echo "[Paths]"
	@$(COMPOSE) exec -T $(SERVICE) bash -lc "test -d $(APP_ROOT)/$(FLUTTER_DIR) && echo 'OK: /app/my_app exists' || (echo 'NG: /app/my_app missing' && exit 1)"
	@$(COMPOSE) exec -T $(SERVICE) bash -lc "test -f $(APP_ROOT)/docker-compose.yml && echo 'OK: /app/docker-compose.yml exists (mounted)' || true"
