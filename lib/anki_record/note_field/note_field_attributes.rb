# frozen_string_literal: true

module AnkiRecord
  ##
  # Module with the NoteField class's attribute readers, writers, and accessors.
  module NoteFieldAttributes
    ##
    # The field's note type.
    attr_reader :note_type

    ##
    # The field's name.
    attr_accessor :name

    ##
    # A boolean that indicates if the field is sticky.
    attr_accessor :sticky

    ##
    # A boolean that indicates if the field is right to left.
    attr_accessor :right_to_left

    ##
    # The field's font style used when editing.
    attr_accessor :font_style

    ##
    # The field's font size used when editing.
    attr_accessor :font_size

    ##
    # The field's description.
    attr_accessor :description

    ##
    # 0 for the first field of the note type, 1 for the second, etc.
    attr_reader :ordinal_number
  end
end
