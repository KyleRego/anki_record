# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"
require_relative "../support/note_type_hashes"

# rubocop:disable RSpec/ExampleLength
RSpec.describe AnkiRecord::NoteType, ".new" do
  include_context "when the anki package is a clean slate"

  context "when passed a name argument" do
    subject(:note_type) { described_class.new anki21_database:, name: }

    let(:name) { "test note type" }

    it "instantiates a non-cloze note type with default CSS styling, no note fields or card templates, and nil deck_id" do
      expect(note_type.anki21_database).to eq anki21_database
      expect(note_type.anki21_database.note_types).to include note_type
      expect(note_type.id).to be_a Integer
      expect(note_type.name).to eq name
      expect(note_type.cloze).to be false
      expect(note_type.usn).to eq(-1)
      expect(note_type.sort_field).to eq 0
      expect(note_type.req).to eq []
      expect(note_type.tags).to be_nil
      expect(note_type.vers).to be_nil
      expect(note_type.card_templates).to eq []
      expect(note_type.note_fields).to eq []
      expect(note_type.deck_id).to be_nil
      expect(note_type.css).to include ".card {"
      expect(note_type.css).to include "color: black;"
      expect(note_type.css).to include "background-color: transparent;"
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

  context "when passed the args hash data of the default Basic Note note type" do
    subject(:basic_note_type_from_hash) do
      basic_note_type_from_hash = described_class.new(anki21_database:, args: basic_model_hash)
      basic_note_type_from_hash.save
      basic_note_type_from_hash
    end

    include_context "when the JSON of a note type from the col record is a Ruby hash"

    it "instantiates a note type from the args hash data including note fields and card template" do
      expect(basic_note_type_from_hash.anki21_database).to eq anki21_database
      expect(anki21_database.note_types).to include basic_note_type_from_hash
      expect(anki21_database.note_types.count).to eq 5
      expect(basic_note_type_from_hash.id).to eq basic_model_hash["id"]
      expect(basic_note_type_from_hash.name).to eq "Basic"
      expect(basic_note_type_from_hash.usn).to eq basic_model_hash["usn"]
      expect(basic_note_type_from_hash.sort_field).to eq basic_model_hash["sortf"]
      expect(basic_note_type_from_hash.req).to eq basic_model_hash["req"]
      expect(basic_note_type_from_hash.tags).to eq basic_model_hash["tags"]
      expect(basic_note_type_from_hash.vers).to eq basic_model_hash["vers"]
      expect(basic_note_type_from_hash.cloze).to be false
      expect(basic_note_type_from_hash.deck_id).to be_nil
      expect(basic_note_type_from_hash.deck).to be_nil
      expect(basic_note_type_from_hash.card_templates.count).to eq 1
      expect(basic_note_type_from_hash.card_templates.first.name).to eq "Card 1"
      expect(basic_note_type_from_hash.card_templates.all? { |obj| obj.instance_of?(AnkiRecord::CardTemplate) }).to be true
      expect(basic_note_type_from_hash.note_fields.count).to eq 2
      expect(basic_note_type_from_hash.note_fields.all? { |obj| obj.instance_of?(AnkiRecord::NoteField) }).to be true
      expect(basic_note_type_from_hash.note_fields.map(&:name).sort).to eq %w[Back Front]
      expect(basic_note_type_from_hash.css).to eq basic_model_hash["css"]
      expect(basic_note_type_from_hash.latex_preamble).to eq basic_model_hash["latexPre"]
      expect(basic_note_type_from_hash.latex_postamble).to eq basic_model_hash["latexPost"]
      expect(basic_note_type_from_hash.latex_svg).to be false
      expect(basic_note_type_from_hash.tags).to be_nil
    end
  end

  context "when passed the args hash data default Basic and Reversed Card note type" do
    subject(:basic_and_reversed_card_note_type_from_existing) do
      described_class.new(anki21_database:, args: basic_and_reversed_card_model_hash)
    end

    include_context "when the JSON of a note type from the col record is a Ruby hash"

    it "instantiates a note type from the args hash data with the two card templates" do
      expect(basic_and_reversed_card_note_type_from_existing.card_templates.count).to eq 2
    end
  end
end
# rubocop:enable RSpec/ExampleLength
