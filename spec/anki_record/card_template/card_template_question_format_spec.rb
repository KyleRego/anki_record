# frozen_string_literal: true

require "./spec/anki_record/support/clean_slate_anki_package"

RSpec.describe AnkiRecord::CardTemplate, "#question_format=" do
  subject(:card_template) { described_class.new(note_type:, name: "test template") }

  include_context "when the anki package is a clean slate"

  let(:note_type) { AnkiRecord::NoteType.new(anki21_database:, name: "test note type for card template") }
  let(:name_argument) { "test template" }

  describe "#question_format=" do
    context "when the format specifies a field name that the card template's note type does not have a field for" do
      it "throws an ArgumentError" do
        expect { card_template.question_format = "{{unknown field}}" }.to raise_error ArgumentError
      end
    end

    context "when the format specifies two field names and the card template's note type has fields for both" do
      it "sets the question_format attribute to the argument" do
        AnkiRecord::NoteField.new note_type:, name: "Front"
        AnkiRecord::NoteField.new note_type:, name: "Back"
        card_template.question_format = "{{Front}} and {{Back}}"
        expect(card_template.question_format).to eq "{{Front}} and {{Back}}"
      end
    end

    context "when the format specifies a cloze field but the note type is not a cloze type" do
      it "throws an ArgumentError" do
        AnkiRecord::NoteField.new note_type:, name: "Front"
        expect { card_template.question_format = "{{cloze:Front}}" }.to raise_error ArgumentError
      end
    end

    context "when the format specifies a cloze field and the note type is not a cloze type" do
      it "sets the question_format attribute to the argument" do
        note_type.cloze = true
        AnkiRecord::NoteField.new note_type:, name: "Front"
        card_template.question_format = "{{cloze:Front}}"
        expect(card_template.question_format).to eq "{{cloze:Front}}"
      end
    end
  end
end
