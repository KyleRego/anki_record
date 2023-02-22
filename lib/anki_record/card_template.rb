# frozen_string_literal: true

require "pry"

module AnkiRecord
  ##
  # CardTemplate represents a card template of an Anki note type
  class CardTemplate
    attr_accessor :name, :question_format, :answer_format, :browser_font_style, :browser_font_size

    attr_reader :note_type, :ordinal_number

    # TODO: All instance variables should at least be readable

    ##
    # Instantiates a new card template for the given note type
    #
    #
    def initialize(note_type:, name: nil, args: nil)
      raise ArgumentError unless (name && args.nil?) || (args && args["name"])

      @note_type = note_type
      if args
        setup_card_template_instance_variables_from_existing(args: args)
      else
        setup_card_template_instance_variables(name: name)
      end
    end

    private

      def setup_card_template_instance_variables_from_existing(args:)
        @name = args["name"]
        @ordinal_number = args["ord"]
        @question_format = args["qfmt"]
        @answer_format = args["afmt"]
        @bqfmt = args["bqfmt"]
        @bafmt = args["bafmt"]
        @deck_id = args["did"]
        @browser_font_style = args["bfont"]
        @browser_font_size = args["bsize"]
      end

      def setup_card_template_instance_variables(name:)
        @name =  name
        @ordinal_number = @note_type.templates.length
        @question_format = ""
        @answer_format = ""
        @bqfmt =  ""
        @bafmt =  ""
        @deck_id = nil
        @browser_font_style = ""
        @browser_font_size = 0
      end

    public

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
