# frozen_string_literal: true

module AnkiRecord
  ##
  # Module with Anki21Database's attribute readers, writers, and accessors
  module Anki21DatabaseAttributes
    ##
    # The database's note types as an array
    attr_reader :note_types

    ##
    # The database's decks as an array
    attr_reader :decks

    ##
    # The database's deck option groups as an array
    attr_reader :deck_options_groups

    ##
    # The database's parent Anki package
    attr_reader :anki_package

    ##
    # The database's collection record
    attr_reader :collection

    ##
    # The database's collection.anki21 SQLite3::Database
    attr_reader :database
  end
end
