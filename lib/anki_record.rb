# frozen_string_literal: true

require "securerandom"
require "sqlite3"
require "zip"

require_relative "anki_record/anki_package"
require_relative "anki_record/version"

##
# This module is the namespace for all AnkiRecord classes and modules:
# - AnkiPackage
# - Field
# - NoteType
# - Template
# - TimeHelper
module AnkiRecord
  class Error < StandardError; end # :nodoc:
end
