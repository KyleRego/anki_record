# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"

# TODO: Refactor to have less contexts
RSpec.describe AnkiRecord::Note, "#respond_to_missing?" do
  subject(:note) do
    basic_note_type = collection.find_note_type_by name: "Basic"
    default_deck = collection.find_deck_by name: "Default"
    described_class.new deck: default_deck, note_type: basic_note_type
  end

  include_context "when the anki package is a clean slate"

  after { cleanup_test_files(directory: ".") }

  context "when the missing method ends with '='" do
    context "when the method corresponds to one of the snake_case note type field names" do
      it "returns true" do
        expect(note.respond_to?(:front=)).to be true
      end
    end

    context "when the method does not correspond to one of the snake_case note type field names" do
      it "returns false" do
        expect(note.respond_to?(:made_up=)).to be false
      end
    end
  end

  context "when the missing method does not end with =" do
    context "when the missing method corresponds to one of the snake_case note type field names" do
      it "returns true" do
        expect(note.respond_to?(:front)).to be true
      end
    end

    context "when the missing method does not correspond to one of the snake_case note type field names" do
      it "returns false" do
        expect(note.respond_to?(:made_up)).to be false
      end
    end
  end
end
