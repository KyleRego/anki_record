# frozen_string_literal: true

module AnkiRecord
  ##
  # Module with the Card class's attribute readers, writers, and accessors.
  module DeckOptionsGroupAttributes
    attr_reader :anki21_database

    ##
    # The deck option group's name.
    attr_accessor :name

    ##
    # The deck option group's id.
    attr_reader :id

    ##
    # The number of milliseconds since the 1970 epoch at which the deck options group was modified.
    attr_reader :last_modified_timestamp
  end
end
