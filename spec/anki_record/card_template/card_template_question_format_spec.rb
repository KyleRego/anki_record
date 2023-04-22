# frozen_string_literal: true

require "./spec/anki_record/support/card_template_shared_context"

RSpec.describe AnkiRecord::CardTemplate, "#question_format=" do
  subject(:card_template_from_existing) { described_class.new(note_type: note_type_argument, args: card_template_hash) }

  include_context "card template helpers"

  let(:note_type_argument) { AnkiRecord::NoteType.new(collection: collection_argument, name: "test note type for templates") }
  let(:name_argument) { "test template" }

  describe "#question_format=" do
    context "when the format specifies a field name that the card template's note type does not have a field for" do
      it "throws an ArgumentError" do
        expect { card_template_from_existing.question_format = "{{unknown field}}" }.to raise_error ArgumentError
      end
    end

    context "when the format specifies two field names and the card template's note type has fields for both" do
      it "sets the question_format attribute to the argument" do
        AnkiRecord::NoteField.new note_type: note_type_argument, name: "Front"
        AnkiRecord::NoteField.new note_type: note_type_argument, name: "Back"
        card_template_from_existing.question_format = "{{Front}} and {{Back}}"
        expect(card_template_from_existing.question_format).to eq "{{Front}} and {{Back}}"
      end
    end

    context "when the format specifies a cloze field but the note type is not a cloze type" do
      it "throws an ArgumentError" do
        AnkiRecord::NoteField.new note_type: note_type_argument, name: "Front"
        expect { card_template_from_existing.question_format = "{{cloze:Front}}" }.to raise_error ArgumentError
      end
    end

    context "when the format specifies a cloze field and the note type is not a cloze type" do
      it "sets the question_format attribute to the argument" do
        note_type_argument.cloze = true
        AnkiRecord::NoteField.new note_type: note_type_argument, name: "Front"
        card_template_from_existing.question_format = "{{cloze:Front}}"
        expect(card_template_from_existing.question_format).to eq "{{cloze:Front}}"
      end
    end
  end
end
