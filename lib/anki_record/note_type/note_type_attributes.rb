# frozen_string_literal: true

module AnkiRecord
  ##
  # Module with the NoteType class's attribute readers, writers, and accessors.
  module NoteTypeAttributes
    ##
    # The note type's collection object.
    attr_reader :collection

    ##
    # The note type's id.
    attr_reader :id

    ##
    # The note type's name.
    attr_accessor :name

    ##
    # A boolean that indicates if this note type is a cloze-deletion note type.
    attr_accessor :cloze

    ##
    # The number of seconds since the 1970 epoch at which the note type was last modified.
    attr_reader :last_modified_timestamp

    ##
    # The note type's update sequence number.
    attr_reader :usn

    ##
    # The note type's sort field.
    attr_reader :sort_field

    ##
    # The note type's CSS.
    attr_accessor :css

    ##
    # The note type's LaTeX preamble.
    attr_reader :latex_preamble

    ##
    # The note type's LaTeX postamble.
    attr_reader :latex_postamble

    ##
    # The note type's card template objects, as an array.
    attr_reader :card_templates

    ##
    # The note type's field objects, as an array.
    attr_reader :note_fields

    ##
    # The note type's deck's id.
    attr_reader :deck_id

    ##
    # The note type's deck.
    def deck
      return nil unless @deck_id

      @collection.find_deck_by id: @deck_id
    end

    ##
    # Sets the note type's deck object.
    def deck=(deck)
      unless deck.instance_of?(AnkiRecord::Deck)
        raise ArgumentError,
              "You can only set this attribute to an instance of AnkiRecord::Deck."
      end

      @deck_id = deck.id
    end

    attr_reader :latex_svg, :tags, :req, :vers
  end
end
