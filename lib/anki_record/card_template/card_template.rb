# frozen_string_literal: true

require_relative "card_template_attributes"

module AnkiRecord
  ##
  # CardTemplate represents a card template of an Anki note type.
  class CardTemplate
    include CardTemplateAttributes

    # Instantiates a new card template with name +name+ for the note type +note_type+.
    def initialize(note_type:, name: nil, args: nil)
      raise ArgumentError unless (name && args.nil?) || (args && args["name"])

      @note_type = note_type
      if args
        setup_card_template_instance_variables_from_existing(args:)
      else
        setup_card_template_instance_variables(name:)
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
