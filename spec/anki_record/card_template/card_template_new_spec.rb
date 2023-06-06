# frozen_string_literal: true

require "./spec/anki_record/support/card_template_hash"
require "./spec/anki_record/support/clean_slate_anki_package"

RSpec.describe AnkiRecord::CardTemplate, ".new" do
  include_context "when the anki package is a clean slate"

  context "when passed a name and note type that has 0 card templates" do
    subject(:template) { described_class.new(note_type:, name: name_argument) }

    let(:note_type) { AnkiRecord::NoteType.new(anki21_database:, name: "test note type for card template") }
    let(:name_argument) { "test template" }

    # rubocop:disable RSpec/ExampleLength
    it "instantiates a card template with ordinal number 0 belonging to the note type" do
      expect(template.note_type).to eq note_type
      expect(template.note_type.card_templates).to include template
      expect(template.name).to eq name_argument
      expect(template.question_format).to eq ""
      expect(template.answer_format).to eq ""
      expect(template.browser_font_style).to eq ""
      expect(template.browser_font_size).to eq 0
      expect(template.ordinal_number).to eq 0
    end
    # rubocop:enable RSpec/ExampleLength
  end

  context "when passed a name and a note type that already has 1 card template" do
    subject(:template) { described_class.new(note_type:, name: name_argument) }

    let(:note_type) do
      note_type = AnkiRecord::NoteType.new(anki21_database:, name: "test note type for card template")
      described_class.new(note_type:, name: "first test template")
      note_type
    end
    let(:name_argument) { "test template" }

    it "instantiates a card template with ordinal number 1" do
      expect(template.ordinal_number).to eq 1
    end
  end

  context "when passed both a name and args hash" do
    include_context "when the JSON of a card template from the col record is a Ruby hash"
    let(:note_type) { AnkiRecord::NoteType.new(anki21_database:, name: "test note type for card template") }

    it "throws an ArgumentError" do
      expect { described_class.new(note_type:, name: "test", args: {}) }.to raise_error ArgumentError
    end
  end

  context "when passed a hash of data for a card template" do
    subject(:card_template_from_hash) { described_class.new(note_type:, args: basic_note_first_card_template_hash) }

    include_context "when the JSON of a card template from the col record is a Ruby hash"
    let(:note_type) { AnkiRecord::NoteType.new(anki21_database:, name: "test note type for card template") }

    # rubocop:disable RSpec/ExampleLength
    it "instantiates a card template from the raw data" do
      expect(card_template_from_hash.note_type).to eq note_type
      expect(card_template_from_hash.note_type.card_templates).to include card_template_from_hash
      expect(card_template_from_hash.name).to eq "Card 1"
      expect(card_template_from_hash.ordinal_number).to eq 0
      expect(card_template_from_hash.question_format).to eq "{{Front}}"
      expect(card_template_from_hash.answer_format).to eq "{{FrontSide}}\n\n<hr id=answer>\n\n{{Back}}"
      expect(card_template_from_hash.browser_font_style).to eq ""
      expect(card_template_from_hash.browser_font_size).to eq 0
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
