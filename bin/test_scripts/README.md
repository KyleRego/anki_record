# Integration

This directory has test scripts that create Anki package files. These are integration tests with a manual step; the test passes when the Anki package file imports correctly into Anki.

These tests should be performed after the RSpec test suite passes. If the Anki packages these scripts create are already present, these scripts will throw an error. The RSpec tests always leave the root directory with no `.apkg` files.
