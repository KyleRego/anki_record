# frozen_string_literal: true

require "pry"

module AnkiRecord
  ##
  # Template represents a card template of an Anki note type
  class Template
    attr_accessor :name

    attr_reader :note_type, :ordinal_number

    ##
    # Instantiates a new template for the given note type
    def initialize(note_type:, name:)
      @note_type = note_type
      @name = name
      @ordinal_number = @note_type.templates.length
      @question_format = ""
      @answer_format = ""
      @bqfmt = ""
      @bafmt = ""
      @deck_id = nil
      @bfont = ""
      @bsize = 0
    end

    ##
    # Returns the field names that are allowed in the answer format and question format
    #
    # These are the field_name values in {{field_name}}
    # andnd are equivalent to the names of the fields of the template's note type
    def allowed_field_names
      @note_type.fields.map(&:name)
    end
  end
end
