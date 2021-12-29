SHELL = /bin/bash

.PHONY: test
test:
	@swift test

.PHONY: build
build:
	@which swift
	@swift build --configuration release --disable-sandbox -Xswiftc -warnings-as-errors
	@mv .build/release/clue-cli .build/release/clue
