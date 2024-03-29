# frozen_string_literal: true

module AnkiRecord
  ##
  # Module with the CardTemplate class's attribute readers, writers, and accessors.
  module CardTemplateAttributes
    ##
    # The card template's name
    attr_accessor :name

    ##
    # The card template's font style in the browser
    attr_accessor :browser_font_style

    ##
    # The card template's font size used in the browser
    attr_accessor :browser_font_size

    ##
    # The card template's question format
    attr_reader :question_format

    ##
    # Sets the question format of the card template
    #
    # Raises an ArgumentError if the specified format attempts to use invalid fields
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
    # The card template's answer format
    attr_reader :answer_format

    ##
    # Sets the answer format of the card template
    #
    # Raises an ArgumentError if the specified format attempts to use invalid fields
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
    # The card template's note type object
    attr_reader :note_type

    ##
    # 0 for the first card template of the note type, 1 for the second, etc
    attr_reader :ordinal_number
  end
end
