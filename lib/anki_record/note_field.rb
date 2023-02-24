# frozen_string_literal: true

# TODO: raise exceptions on invalid assignment to prevent downstream errors and specs for the writeable attributes
# TODO: All instance variables should at least be readable

require "pry"

module AnkiRecord
  ##
  # NoteField represents a field of an Anki note type
  class NoteField
    DEFAULT_FIELD_FONT_STYLE = "Arial"
    DEFAULT_FIELD_FONT_SIZE = 20
    DEFAULT_FIELD_DESCRIPTION = ""
    private_constant :DEFAULT_FIELD_FONT_STYLE, :DEFAULT_FIELD_FONT_SIZE, :DEFAULT_FIELD_DESCRIPTION

    ##
    # The name of the note field
    attr_accessor :name

    ##
    # One of many attributes that is readable and writeable but needs to be documented
    attr_accessor :sticky, :right_to_left, :font_style, :font_size, :description

    ##
    # One of many attributes that is currently read-only and needs to be documented.
    attr_reader :note_type, :ordinal_number

    ##
    # Instantiates a new field for the given note type
    def initialize(note_type:, name: nil, args: nil)
      raise ArgumentError unless (name && args.nil?) || (args && args["name"])

      @note_type = note_type
      if args
        setup_note_field_instance_variables_from_existing(args: args)
      else
        setup_note_field_instance_variables(name: name)
      end
    end

    private

      def setup_note_field_instance_variables_from_existing(args:)
        @name = args["name"]
        @ordinal_number = args["ord"]
        @sticky = args["sticky"]
        @right_to_left = args["rtl"]
        @font_style = args["font"]
        @font_size = args["size"]
      end

      def setup_note_field_instance_variables(name:)
        @name = name
        @ordinal_number = @note_type.fields.length
        @sticky = false
        @right_to_left = false
        @font_style = DEFAULT_FIELD_FONT_STYLE
        @font_size = DEFAULT_FIELD_FONT_SIZE
        @description = DEFAULT_FIELD_DESCRIPTION
      end
  end
end
