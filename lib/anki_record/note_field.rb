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
    # The note type object that the note field object belongs to
    attr_reader :note_type

    ##
    # The name of the note field
    attr_accessor :name

    ##
    # A boolean that indicates if this field is sticky
    attr_accessor :sticky

    ##
    # A boolean that indicates if this field should be right to left in Anki
    attr_accessor :right_to_left

    ##
    # The font style used when editing the field in Anki
    attr_accessor :font_style

    ##
    # The font size used when editing the field in Anki
    attr_accessor :font_size

    ##
    # The description of the note field
    attr_accessor :description

    ##
    # 0 for the first field of the note type, 1 for the second, etc.
    attr_reader :ordinal_number

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

      @note_type.add_note_field self
    end

    def to_h # :nodoc:
      {
        name: @name,
        ord: @ordinal_number,
        sticky: @sticky,
        rtl: @right_to_left,
        font: @font_style,
        size: @font_size,
        description: @description
      }
    end

    private

      def setup_note_field_instance_variables_from_existing(args:)
        @name = args["name"]
        @ordinal_number = args["ord"]
        @sticky = args["sticky"]
        @right_to_left = args["rtl"]
        @font_style = args["font"]
        @font_size = args["size"]
        @description = args["description"]
      end

      def setup_note_field_instance_variables(name:)
        @name = name
        @ordinal_number = @note_type.note_fields.length
        @sticky = false
        @right_to_left = false
        @font_style = DEFAULT_FIELD_FONT_STYLE
        @font_size = DEFAULT_FIELD_FONT_SIZE
        @description = DEFAULT_FIELD_DESCRIPTION
      end
  end
end
