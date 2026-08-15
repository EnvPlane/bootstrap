.PHONY: test lint test-integration test-sql-bootstrap-claim test-brand-release-e2e-contract

test:
	go test ./...

lint:
	golangci-lint run

test-integration:
	go test -tags=integration ./...

test-sql-bootstrap-claim:
	go test -tags=integration ./internal/store -run TestSQLBootstrapSessionStoreClaimBootstrapTokenIsAtomic -count=1

test-brand-release-e2e-contract:
	bash scripts/tests/test-brand-release-e2e-contract.sh
