# frozen_string_literal: true

require "sqlite3"
require "zip"

require_relative "anki_record/anki_package"
require_relative "anki_record/version"

##
# This module is the namespace for all AnkiRecord classes:
# - AnkiPackage
# - Card
# - CardTemplate
# - Collection
# - DeckOptionsGroup
# - Deck
# - Note
# - NoteField
# - NoteType
#
# And modules:
# - SharedConstantsHelper
# - TimeHelper
module AnkiRecord
  class Error < StandardError; end # :nodoc:
end
