SHELL = /bin/bash
ifeq ($(shell uname),Darwin)
EXTRA_SWIFT_FLAGS = "--disable-sandbox"
else
SWIFT_TOOLCHAIN = "$(shell dirname $(shell swift -print-target-info | grep runtimeResourcePath | cut -f 2 -d ':' | cut -f 2 -d '"'))"
EXTRA_SWIFT_FLAGS = -Xcxx -I${SWIFT_TOOLCHAIN}/swift -Xcxx -I${SWIFT_TOOLCHAIN}/swift/Block
endif

.PHONY: test
test:
	@swift test ${EXTRA_SWIFT_FLAGS}

.PHONY: build
build:
	@swift build --configuration release -Xswiftc -warnings-as-errors ${EXTRA_SWIFT_FLAGS}
