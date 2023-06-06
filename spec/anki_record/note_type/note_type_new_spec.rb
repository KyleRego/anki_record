# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"
require_relative "../support/note_type_hashes"

# TODO: Specs can be refactored for performance.
RSpec.describe AnkiRecord::NoteType, ".new" do
  include_context "when the anki package is a clean slate"

  context "when passed a name argument" do
    subject(:note_type) { described_class.new anki21_database:, name: }

    let(:name) { "test note type" }

    it "instantiates a note type with anki21_database attribute equal to the anki21_database argument" do
      expect(note_type.anki21_database).to eq anki21_database
    end

    it "instantiates a new note type which is added to the anki21_database's note_types attribute" do
      expect(note_type.anki21_database.note_types).to include note_type
    end

    it "instantiates a note type with an integer id" do
      expect(note_type.id).to be_a Integer
    end

    it "instantiates a note type with name attribute equal to the name argument" do
      expect(note_type.name).to eq name
    end

    it "instantiates a non-cloze note type (a note type with the cloze attribute being false)" do
      expect(note_type.cloze).to be false
    end

    it "instantiates a note type with usn attribute equal to -1" do
      expect(note_type.usn).to eq(-1)
    end

    it "instantiates a note type with sort_field attribute equal to 0" do
      expect(note_type.sort_field).to eq 0
    end

    it "instantiates a note type object with req attribute equal to an empty array" do
      expect(note_type.req).to eq []
    end

    it "instantiates a note type object with tags attribute being nil" do
      expect(note_type.tags).to be_nil
    end

    it "instantiates a note type object with vers attribute being nil" do
      expect(note_type.vers).to be_nil
    end

    it "instantiates a note type with the card_templates attribute being an empty array" do
      expect(note_type.card_templates).to eq []
    end

    it "instantiates a note type with the note_fields attribute being an empty array" do
      expect(note_type.note_fields).to eq []
    end

    it "instantiates a note type with a deck_id attribute of nil" do
      expect(note_type.deck_id).to be_nil
    end

    it "instantiates a note type with default CSS styling that defines styling for the 'card' CSS class" do
      expect(note_type.css).to include ".card {"
    end

    it "instantiates a note type with default CSS styling that includes .card: color: black;" do
      expect(note_type.css).to include "color: black;"
    end

    it "instantiates a note type with default CSS styling that includes .card: background-color: transparent;" do
      expect(note_type.css).to include "background-color: transparent;"
    end

    it "instantiates a note type with default CSS styling that includes .card: text-align: center;" do
      expect(note_type.css).to include "text-align: center;"
    end
  end

  context "when passed no name or args arguments" do
    let(:note_type_instantiated_with_only_anki21_database) do
      described_class.new(anki21_database:)
    end

    it "throws an ArgumentError" do
      expect { note_type_instantiated_with_only_anki21_database }.to raise_error ArgumentError
    end
  end

  context "when passed name and args arguments" do
    let(:note_type_instantiated_with_both_args_and_name) do
      described_class.new(anki21_database:, name: "namo", args: {})
    end

    it "throws an ArgumentError" do
      expect { note_type_instantiated_with_both_args_and_name }.to raise_error ArgumentError
    end
  end

  context "when passed an args hash (of the existing default basic note type)" do
    subject(:basic_note_type_from_hash) do
      basic_note_type_from_hash = described_class.new(anki21_database:, args: basic_model_hash)
      basic_note_type_from_hash.save
      basic_note_type_from_hash
    end

    include_context "when the JSON of a note type from the col record is a Ruby hash"

    it "instantiates a note type with anki21_database attribute equal to the anki21_database argument" do
      expect(basic_note_type_from_hash.anki21_database).to eq anki21_database
    end

    it "instantiates a new note type which is added to the anki21_database's note_types attribute" do
      expect(anki21_database.note_types).to include basic_note_type_from_hash
    end

    it "does not change the number of note types in the anki21_database's note_types attribute" do
      expect(anki21_database.note_types.count).to eq 5
    end

    it "instantiates a note type object with id the same as the data" do
      expect(basic_note_type_from_hash.id).to eq basic_model_hash["id"]
    end

    it "instantiates a note type object with the same name as the data ('Basic')" do
      expect(basic_note_type_from_hash.name).to eq "Basic"
    end

    it "instantiates a note type object with the same usn as the data" do
      expect(basic_note_type_from_hash.usn).to eq basic_model_hash["usn"]
    end

    it "instantiates a note type object with sort_field attribute equal to the data's sortf value" do
      expect(basic_note_type_from_hash.sort_field).to eq basic_model_hash["sortf"]
    end

    it "instantiates a note type object with req attribute equal to the data's req value" do
      expect(basic_note_type_from_hash.req).to eq basic_model_hash["req"]
    end

    it "instantiates a note type object with tags attribute equal to the data's tags value" do
      expect(basic_note_type_from_hash.tags).to eq basic_model_hash["tags"]
    end

    it "instantiates a note type object with vers attribute equal to the data's vers value" do
      expect(basic_note_type_from_hash.vers).to eq basic_model_hash["vers"]
    end

    it "instantiates a non-cloze note type" do
      expect(basic_note_type_from_hash.cloze).to be false
    end

    it "instantiates a note type with the same deck id as the data (NULL or nil)" do
      expect(basic_note_type_from_hash.deck_id).to be_nil
    end

    it "instantiates a note type where the deck method returns nil" do
      expect(basic_note_type_from_hash.deck).to be_nil
    end

    it "instantiates a note type with one card template" do
      expect(basic_note_type_from_hash.card_templates.count).to eq 1
    end

    it "instantiates a note type with a template with the name Card 1" do
      expect(basic_note_type_from_hash.card_templates.first.name).to eq "Card 1"
    end

    it "instantiates a note type with a template that is of type CardTemplate" do
      expect(basic_note_type_from_hash.card_templates.all? { |obj| obj.instance_of?(AnkiRecord::CardTemplate) }).to be true
    end

    it "instantiates a note type with 2 fields" do
      expect(basic_note_type_from_hash.note_fields.count).to eq 2
    end

    it "instantiates a note type with 2 fields that are of class NoteField" do
      expect(basic_note_type_from_hash.note_fields.all? { |obj| obj.instance_of?(AnkiRecord::NoteField) }).to be true
    end

    it "instantiates a note type with a 'Front' field and a 'Back' field" do
      expect(basic_note_type_from_hash.note_fields.map(&:name).sort).to eq %w[Back Front]
    end

    it "instantiates a note type with the CSS styling from the data" do
      expect(basic_note_type_from_hash.css).to eq basic_model_hash["css"]
    end

    it "instantiates a note type with the data's LaTeX preamble" do
      expect(basic_note_type_from_hash.latex_preamble).to eq basic_model_hash["latexPre"]
    end

    it "instantiates a note type with the data's LaTeX postamble" do
      expect(basic_note_type_from_hash.latex_postamble).to eq basic_model_hash["latexPost"]
    end

    it "instantiates a note type with latex_svg false" do
      expect(basic_note_type_from_hash.latex_svg).to be false
    end

    it "instantiates a note type with nil tags attribute because it is missing from the data" do
      expect(basic_note_type_from_hash.tags).to be_nil
    end
  end

  context "when passed an args hash (of the default basic and reversed card note type)" do
    subject(:basic_and_reversed_card_note_type_from_existing) do
      described_class.new(anki21_database:, args: basic_and_reversed_card_model_hash)
    end

    include_context "when the JSON of a note type from the col record is a Ruby hash"

    it "instantiates a note type with two card templates" do
      expect(basic_and_reversed_card_note_type_from_existing.card_templates.count).to eq 2
    end
  end
end
