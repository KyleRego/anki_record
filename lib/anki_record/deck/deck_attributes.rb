# frozen_string_literal: true

module AnkiRecord
  # Module with the Deck class's attribute readers, writers, and accessors.
  module DeckAttributes
    attr_reader :anki21_database

    ##
    # The deck's name.
    attr_accessor :name

    ##
    # The deck's description.
    attr_accessor :description

    ##
    # The deck's id.
    attr_reader :id

    ##
    # The number of seconds since the 1970 epoch when the deck was last modified.
    attr_reader :last_modified_timestamp

    ##
    # The deck's deck options group object.
    attr_reader :deck_options_group
  end
end
