#!/bin/bash

# Fast fail the script on failures.   
set -e

dart --checked test/harness_console.dart

# Install dart_coveralls; gather and send coverage data.
if [ "$COVERALLS_TOKEN" ] && [ "$TRAVIS_DART_VERSION" = "stable" ]; then
  pub global run dart_coveralls report \
    --token $COVERALLS_TOKEN \
    --retry 2 \
    --exclude-test-files \
    test/harness_console.dart
fi
