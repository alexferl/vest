.PHONY: build dev test fmt pre-commit

.DEFAULT: help
help:
	@echo "make dev"
	@echo "	setup development environment"
	@echo "make test"
	@echo "	run go test"
	@echo "make fmt"
	@echo "	run go fmt"
	@echo "make pre-commit"
	@echo "	run pre-commit"

dev:
	@type pre-commit > /dev/null || (echo "ERROR: pre-commit (https://pre-commit.com/) is required."; exit 1)
	pre-commit install

test:
	v -stats test .

fmt:
	v fmt -w .

pre-commit:
	pre-commit
