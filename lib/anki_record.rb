# frozen_string_literal: true

require "securerandom"
require "sqlite3"
require "zip"

require_relative "anki_record/anki_package"
require_relative "anki_record/version"

##
# This module is the namespace for all AnkiRecord classes
# - AnkiPackage
# - CardTemplate
# - Collection
# - DeckOptionsGroup
# - Deck
# - NoteField
# - NoteType
#
# And modules:
# - SharedConstantsHelper
# - TimeHelper
module AnkiRecord
  class Error < StandardError; end # :nodoc:
end
