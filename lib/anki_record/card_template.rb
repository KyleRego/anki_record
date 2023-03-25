# frozen_string_literal: true

module AnkiRecord
  ##
  # CardTemplate represents a card template of an Anki note type.
  class CardTemplate
    ##
    # The card template's name.
    attr_accessor :name

    ##
    # The card template's font style in the browser.
    attr_accessor :browser_font_style

    ##
    # The card template's font size used in the browser.
    attr_accessor :browser_font_size

    ##
    # The card template's question format.
    attr_reader :question_format

    ##
    # Sets the question format of the card template.
    #
    # Raises an ArgumentError if the specified format attempts to use invalid fields.
    def question_format=(format)
      fields_in_specified_format = format.scan(/{{.+?}}/).map do |capture|
        capture.chomp("}}").reverse.chomp("{{").reverse
      end
      if fields_in_specified_format.any? do |field_name|
        !note_type.allowed_card_template_question_format_field_names.include?(field_name)
      end
        raise ArgumentError, "You tried to use a field that the note type does not have."
      end

      @question_format = format
    end

    ##
    # The card template's answer format.
    attr_reader :answer_format

    ##
    # Sets the answer format of the card template.
    #
    # Raises an ArgumentError if the specified format attempts to use invalid fields.
    def answer_format=(format)
      fields_in_specified_format = format.scan(/{{.+?}}/).map do |capture|
        capture.chomp("}}").reverse.chomp("{{").reverse
      end
      if fields_in_specified_format.any? do |field_name|
        !note_type.allowed_card_template_answer_format_field_names.include?(field_name)
      end
        raise ArgumentError, "You tried to use a field that the note type does not have."
      end

      @answer_format = format
    end

    ##
    # The card template's note type object.
    attr_reader :note_type

    ##
    # 0 for the first card template of the note type, 1 for the second, etc.
    attr_reader :ordinal_number

    # Instantiates a new card template with name +name+ for the note type +note_type+.
    def initialize(note_type:, name: nil, args: nil)
      raise ArgumentError unless (name && args.nil?) || (args && args["name"])

      @note_type = note_type
      if args
        setup_card_template_instance_variables_from_existing(args: args)
      else
        setup_card_template_instance_variables(name: name)
      end

      @note_type.add_card_template self
    end

    def to_h # :nodoc:
      {
        name: @name,
        ord: @ordinal_number,
        qfmt: @question_format, afmt: @answer_format,
        bqfmt: @bqfmt,
        bafmt: @bafmt,
        did: @deck_id,
        bfont: @browser_font_style,
        bsize: @browser_font_size
      }
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
  end
end
