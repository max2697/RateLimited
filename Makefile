PROJECT := RateLimited.xcodeproj
SCHEME := RateLimited
DEST := platform=macOS

.PHONY: build run clean icon test lint format check

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination '$(DEST)' build CODE_SIGNING_ALLOWED=NO

run:
	open RateLimited.xcodeproj

clean:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) clean CODE_SIGNING_ALLOWED=NO

icon:
	swift scripts/generate_app_icon.swift

test:
	swift test

lint:
	swiftformat --lint .
	swiftlint --strict

format:
	swiftformat .

check: test build
