SHELL = /bin/bash

.PHONY: test
test:
	@swift test

.PHONY: build
build:
	@swift build --configuration release --disable-sandbox -Xswiftc -warnings-as-errors
	@mv .build/release/clue-cli .build/release/clue
