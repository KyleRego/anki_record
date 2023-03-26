# frozen_string_literal: true

require "sqlite3"
require "zip"

require_relative "anki_record/anki_package/anki_package"
require_relative "anki_record/version"

module AnkiRecord
  class Error < StandardError; end # :nodoc:
end
