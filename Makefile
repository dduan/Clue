SHELL = /bin/bash
ifeq ($(shell uname),Darwin)
EXTRA_SWIFT_FLAGS = "--disable-sandbox"
else
SWIFT_TOOLCHAIN = "$(shell dirname $(shell swift -print-target-info | grep runtimeResourcePath | cut -f 2 -d ':' | cut -f 2 -d '"'))"
EXTRA_SWIFT_FLAGS = -Xcxx -I${SWIFT_TOOLCHAIN}/swift -Xcxx -I${SWIFT_TOOLCHAIN}/swift/Block
endif

define build
	@swift build --configuration $(1) -Xswiftc -warnings-as-errors ${EXTRA_SWIFT_FLAGS}
	@cp .build/$(1)/clue-cli .build/$(1)/clue
endef

.PHONY: test
test:
	@swift test ${EXTRA_SWIFT_FLAGS}

.PHONY: build
build:
	$(call build,release)

.PHONY: debug
debug:
	$(call build,debug)
