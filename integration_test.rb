# frozen_string_literal: true

require "anki_record"

db = AnkiRecord::AnkiPackage.new name: "test"
db.zip_and_close
