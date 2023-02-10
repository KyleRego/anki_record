# frozen_string_literal: true

require "securerandom"
require "sqlite3"
require "zip"

require_relative "anki_record/anki_database"
require_relative "anki_record/version"

module AnkiRecord
  class Error < StandardError; end
end
