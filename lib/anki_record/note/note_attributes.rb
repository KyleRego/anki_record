# frozen_string_literal: true

module AnkiRecord
  # Module with the Note class's attribute readers, writers, and accessors.
  module NoteAttributes
    ##
    # The note's id.
    attr_reader :id

    ##
    # The note's globally unique id.
    attr_accessor :guid

    ##
    # The number of seconds since the 1970 epoch at which the note was last modified.
    attr_reader :last_modified_timestamp

    ##
    # The note's update sequence number.
    attr_reader :usn

    ##
    # The note's tags, as an array. The tags are strings.
    attr_reader :tags

    ##
    # The note's field contents, as a hash.
    attr_reader :field_contents

    ##
    # The note's deck object.
    #
    # When the note is saved, the cards will belong to this deck.
    attr_reader :deck

    ##
    # The note's note type object.
    attr_reader :note_type

    ##
    # The note's collection object.
    attr_reader :collection

    ##
    # The note's card objects, as an array.
    attr_reader :cards

    ##
    # Corresponds to the flags column in the collection.anki21 notes table.
    attr_reader :flags

    ##
    # Corresponds to the data column in the collection.anki21 notes table.
    attr_reader :data
  end
end
