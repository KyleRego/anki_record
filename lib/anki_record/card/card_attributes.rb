# frozen_string_literal: true

module AnkiRecord
  ##
  # Module with the Card class's attribute readers, writers, and accessors.
  module CardAttributes
    # :nodoc:
    attr_reader :anki21_database

    ##
    # The card's note.
    attr_reader :note

    ##
    # The card's deck.
    attr_reader :deck

    ##
    # The card's card template.
    attr_reader :card_template

    ##
    # The card's id.
    #
    # This is also the number of milliseconds since the 1970 epoch when the card was created.
    attr_reader :id

    ##
    # The number of seconds since the 1970 epoch when the card was last modified.
    attr_reader :last_modified_timestamp

    ##
    # The card's update sequence number.
    attr_reader :usn

    attr_reader :type, :queue, :due, :ivl, :factor, :reps, :lapses, :left, :odue, :odid, :flags, :data
  end
end
