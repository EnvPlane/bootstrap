.PHONY: test run build docker-build docker-build-frontend helm-template dev dev-down dev-logs test-integration test-sql-bootstrap-claim

test:
	go test ./...

run:
	go run ./apps/api

build:
	go build -o bin/envpilot ./apps/api

docker-build:
	docker build -t envpilot:local .

docker-build-frontend:
	docker build -f apps/frontend/Dockerfile -t envpilot-frontend:local .

helm-template:
	helm template envpilot deploy/helm/envpilot-control-plane

dev:
	docker compose up --build

dev-down:
	docker compose down --remove-orphans

dev-logs:
	docker compose logs -f api postgres redis

test-integration:
	go test -tags=integration ./...

test-sql-bootstrap-claim:
	go test -tags=integration ./internal/store -run TestSQLBootstrapSessionStoreClaimBootstrapTokenIsAtomic -count=1
