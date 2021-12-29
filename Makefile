SHELL = /bin/bash

.PHONY: test
test:
	@swift test

.PHONY: build
build:
ifeq ($(shell uname),Darwin)
	@swift build --configuration release --disable-sandbox -Xswiftc -warnings-as-errors
else
	@swift xxx
endif
	@mv .build/release/clue-cli .build/release/clue
