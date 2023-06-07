# frozen_string_literal: true

module AnkiRecord
  ##
  # Module with the Anki21Database class's attribute readers, writers, and accessors.
  module Anki21DatabaseAttributes
    ##
    # The database's note type objects as an array.
    attr_reader :note_types

    ##
    # The database's deck objects as an array
    attr_reader :decks

    ##
    # The database's deck option group objects as an array.
    attr_reader :deck_options_groups

    attr_reader :anki_package, :collection, :database
  end
end
