# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"

RSpec.describe AnkiRecord::Note, "#method_missing" do
  subject(:note) do
    basic_note_type = anki21_database.find_note_type_by(name: "Basic")
    default_deck = anki21_database.find_deck_by(name: "Default")
    described_class.new(deck: default_deck, note_type: basic_note_type)
  end

  include_context "when the anki package is a clean slate"

  context "when the missing method ends with '='" do
    it "throws an error if the method does not correspond to one of the note type field names" do
      expect { note.made_up_field = "Made up" }.to raise_error NoMethodError
    end

    it "sets the field if the method corresponds to one of the note type field names" do
      note.front = "Content of the note Front field"
      expect(note.front).to eq "Content of the note Front field"
    end
  end

  context "when the missing method does not end with '=" do
    it "throws an error if the method does not correspond to one of the note type field names" do
      expect { note.what_this_method }.to raise_error NoMethodError
    end

    context "when the method corresponds to one of the note type field names" do
      it "returns blank string if that field has not been set" do
        expect(note.front).to eq ""
        expect(note.back).to eq ""
      end

      # rubocop:disable RSpec/ExampleLength
      it "returns the field value if the field has been set" do
        note_front = "What is 4 * 5?"
        note_back = "It is 20"
        note.front = note_front
        note.back = note_back
        expect(note.front).to eq note_front
        expect(note.back).to eq note_back
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
