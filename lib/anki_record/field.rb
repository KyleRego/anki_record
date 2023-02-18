# frozen_string_literal: true

require "pry"

module AnkiRecord
  ##
  # Field represents a field of an Anki note type
  class Field
    DEFAULT_FIELD_FONT_STYLE = "Arial"
    DEFAULT_FIELD_FONT_SIZE = 20
    DEFAULT_FIELD_DESCRIPTION = ""
    private_constant :DEFAULT_FIELD_FONT_STYLE, :DEFAULT_FIELD_FONT_SIZE, :DEFAULT_FIELD_DESCRIPTION

    attr_accessor :name, :sticky, :right_to_left, :font_style, :font_size # TODO: raise exceptions on invalid assignment to prevent downstream errors and specs testing that

    attr_reader :note_type, :ordinal_number

    ##
    # Instantiates a new field for the given note type
    def initialize(note_type:, name:)
      @note_type = note_type
      @name = name
      @ordinal_number = @note_type.fields.length
      @sticky = false
      @right_to_left = false
      @font_style = DEFAULT_FIELD_FONT_STYLE
      @font_size = DEFAULT_FIELD_FONT_SIZE
    end
  end
end
