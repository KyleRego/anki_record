# frozen_string_literal: true

require_relative "note_field_attributes"
require_relative "note_field_defaults"

module AnkiRecord
  ##
  # NoteField represents a field of an Anki note type.
  class NoteField
    include NoteFieldAttributes
    include NoteFieldDefaults

    ##
    # Instantiates a new field for the note type +note_type+ with name +name+.
    def initialize(note_type:, name: nil, args: nil)
      raise ArgumentError unless (name && args.nil?) || (args && args["name"])

      @note_type = note_type
      if args
        setup_note_field_instance_variables_from_existing(args: args)
      else
        setup_note_field_instance_variables_for_new_field(name: name)
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

      def setup_note_field_instance_variables_for_new_field(name:)
        @name = name
        @ordinal_number = @note_type.note_fields.length
        @sticky = false
        @right_to_left = false
        @font_style = default_field_font_style
        @font_size = default_field_font_size
        @description = default_field_description
      end
  end
end
