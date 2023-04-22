# frozen_string_literal: true

require "./spec/anki_record/support/card_template_spec_helpers"

RSpec.describe AnkiRecord::CardTemplate, ".new" do
  include_context "card template helpers"

  describe "when passed a name and note type with no card templates" do
    subject(:template) { described_class.new(note_type: note_type_argument, name: name_argument) }

    let(:name_argument) { "test template" }

    card_template_new_integration_test_one = <<-DESC
      1. instantiates a card template with note_type attribute equal to the note type argument
      2. instantiates a card template that is added to the note type's card_templates attribute
      3. instantiates a card template with the given name
      4. instantiates a card template with an empty question format (an empty string)
      5. instantiates a card template with an empty answer format (an empty string)
      6. instantiates a card template with an empty browser font style (an empty string)
      7. instantiates a card template with a browser font size of 0
      8. instantiates a card template with ordinal number 0
    DESC

    # rubocop:disable RSpec/ExampleLength
    it(card_template_new_integration_test_one) do
      # 1
      expect(template.note_type).to eq note_type_argument
      # 2
      expect(template.note_type.card_templates).to include template
      # 3
      expect(template.name).to eq name_argument
      # 4
      expect(template.question_format).to eq ""
      # 5
      expect(template.answer_format).to eq ""
      # 6
      expect(template.browser_font_style).to eq ""
      # 7
      expect(template.browser_font_size).to eq 0
      # 8
      expect(template.ordinal_number).to eq 0
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe "when passed a name and a note type with one card template" do
    subject(:template) { described_class.new(note_type: note_type_argument, name: name_argument) }

    let(:name_argument) { "test template" }

    before { described_class.new note_type: note_type_argument, name: "the first card template" }

    it "instantiates a card template with ordinal number 1" do
      expect(template.ordinal_number).to eq 1
    end
  end

  describe "when passed both a name and args hash" do
    it "throws an ArgumentError" do
      expect { described_class.new(note_type: note_type_argument, name: "test", args: {}) }.to raise_error ArgumentError
    end
  end

  describe "::new passed a valid args hash for the default Card 1 template JSON of the default Basic note type" do
    subject(:card_template_from_existing) { described_class.new(note_type: note_type_argument, args: card_template_hash) }

    card_template_new_integration_test_two = <<-DESC
      1. instantiates a card template with note_type attribute equal to the note type argument
      2. instantiates a card template that is added to the note type's card_templates attribute
      3. instantiates a card template with the name Card 1
      4. instantiates a card template with ordinal number 0
      5. instantiates a card template with the data's question format
      6. instantiates a card template with data's answer format
      7. instantiates a template with an empty browser font style
      8. instantiates a template with a browser font size of 0
    DESC

    # rubocop:disable RSpec/ExampleLength
    it(card_template_new_integration_test_two) do
      # 1
      expect(card_template_from_existing.note_type).to eq note_type_argument
      # 2
      expect(card_template_from_existing.note_type.card_templates).to include card_template_from_existing
      # 3
      expect(card_template_from_existing.name).to eq "Card 1"
      # 4
      expect(card_template_from_existing.ordinal_number).to eq 0
      # 5
      expect(card_template_from_existing.question_format).to eq "{{Front}}"
      # 6
      expect(card_template_from_existing.answer_format).to eq "{{FrontSide}}\n\n<hr id=answer>\n\n{{Back}}"
      # 7
      expect(card_template_from_existing.browser_font_style).to eq ""
      # 8
      expect(card_template_from_existing.browser_font_size).to eq 0
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
