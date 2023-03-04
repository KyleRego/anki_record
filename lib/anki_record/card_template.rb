# frozen_string_literal: true

require "pry"

# TODO: All instance variables should at least be readable

module AnkiRecord
  ##
  # CardTemplate represents a card template of an Anki note type
  class CardTemplate
    ##
    # The name of the card template
    attr_accessor :name

    ##
    # The font style shown for the card template in the browser
    attr_accessor :browser_font_style

    ##
    # The font size used for the card template in the browser
    attr_accessor :browser_font_size

    ##
    # The question format of the card template
    #
    # TODO: A custom setter method for this with validation
    attr_reader :question_format

    ##
    # The answer format of the card template
    #
    # TODO: A custom setter method for this with validation
    attr_reader :answer_format

    ##
    # The note type that the card template belongs to
    attr_reader :note_type

    ##
    # 0 for the first card template of the note type, 1 for the second, etc.
    attr_reader :ordinal_number

    ##
    # Instantiates a new card template called +name+ for the given note type
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
        @ordinal_number = @note_type.card_templates.length
        @question_format = ""
        @answer_format = ""
        @bqfmt =  ""
        @bafmt =  ""
        @deck_id = nil
        @browser_font_style = ""
        @browser_font_size = 0
      end

    ##
    # Returns the field names that are allowed in the answer format and question format
    #
    # These are the field_name values in {{field_name}} in those formats.
    #
    # They are equivalent to the names of the fields of the template's note type.
    # TODO: this should be a method of note type e.g. note_type.allowed_field_names
    # def allowed_field_names
    #   @note_type.fields.map(&:name)
    # end
  end
end
