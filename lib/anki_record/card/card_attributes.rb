# frozen_string_literal: true

module AnkiRecord
  ##
  # Module with the Card class's attribute readers, writers, and accessors.
  module CardAttributes
    ##
    # The card's note object.
    attr_reader :note

    ##
    # The card's deck object.
    attr_reader :deck

    ##
    # The card's collection object.
    attr_reader :collection

    ##
    # The card's card template object.
    attr_reader :card_template

    ##
    # The card's id.
    #
    # This is also the number of milliseconds since the 1970 epoch at which the card was created.
    attr_reader :id

    ##
    # The number of seconds since the 1970 epoch at which the card was last modified.
    attr_reader :last_modified_timestamp

    ##
    # The card's update sequence number.
    attr_reader :usn

    attr_reader :type, :queue, :due, :ivl, :factor, :reps, :lapses, :left, :odue, :odid, :flags, :data
  end
end
