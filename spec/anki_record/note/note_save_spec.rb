# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"

# TODO: Refactor to not use one expect per example
RSpec.describe AnkiRecord::Note, "#save" do
  include_context "when the anki package is a clean slate"

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  context "when the note does not exist in the collection.anki21 database (custom note type, 2 card templates)" do
    subject!(:note_with_two_cards) do
      note = described_class.new note_type: custom_note_type, deck: default_deck
      note.custom_front = "Hello"
      note.custom_back = "World"
      note.save
      note
    end

    let(:default_deck) { anki21_database.find_deck_by name: "Default" }
    let(:custom_note_type) do
      custom_note_type = AnkiRecord::NoteType.new anki21_database:, name: "custom note type"
      AnkiRecord::NoteField.new note_type: custom_note_type, name: "custom front"
      AnkiRecord::NoteField.new note_type: custom_note_type, name: "custom back"
      custom_card_template = AnkiRecord::CardTemplate.new note_type: custom_note_type, name: "custom card 1"
      custom_card_template.question_format = "{{custom front}}"
      custom_card_template.answer_format = "{{custom back}}"
      second_custom_card_template = AnkiRecord::CardTemplate.new note_type: custom_note_type, name: "custom card 2"
      second_custom_card_template.question_format = "{{custom back}}"
      second_custom_card_template.answer_format = "{{custom front}}"
      custom_note_type.save
      custom_note_type
    end

    let(:note_record_data) { anki21_database.prepare("select * from notes where id = #{note_with_two_cards.id}").execute.first }
    let(:cards_records_data) { anki21_database.prepare("select * from cards where nid = #{note_with_two_cards.id}").execute.to_a }
    let(:note_count) { anki21_database.prepare("select count(*) from notes;").execute.first["count(*)"] }
    let(:cards_count) { anki21_database.prepare("select count(*) from cards").execute.first["count(*)"] }
    let(:expected_number_of_notes) { 1 }
    let(:expected_number_of_cards) { 2 }

    # rubocop:disable RSpec/ExampleLength
    it "saves the note and associated cards to the collection.anki21 database" do
      expect(note_count).to eq expected_number_of_notes
      expect(note_record_data["id"]).to eq note_with_two_cards.id
      expect(note_record_data["guid"]).to eq note_with_two_cards.guid
      expect(note_record_data["mid"]).to eq note_with_two_cards.note_type.id
      expect(note_record_data["mod"]).to eq note_with_two_cards.last_modified_timestamp
      expect(note_record_data["usn"]).to eq(-1)
      expect(note_record_data["tags"]).to eq ""
      expect(note_record_data["flds"]).to eq "Hello\x1FWorld"
      expect(note_record_data["sfld"]).to eq "Hello"
      expect(note_record_data["csum"].to_s.length).to eq 10
      expect(note_record_data["flags"]).to eq 0
      expect(note_record_data["data"]).to eq ""
      expect(cards_count).to eq expected_number_of_cards
      expect(cards_records_data.map { |hash| hash["id"] }.sort).to eq note_with_two_cards.cards.map(&:id).sort
      expect(cards_records_data.map { |hash| hash["nid"] }).to eq [note_with_two_cards.id] * 2
      expect(cards_records_data.map { |hash| hash["did"] }).to eq [note_with_two_cards.deck.id] * 2
      expect(cards_records_data.map { |hash| hash["ord"] }.sort).to eq note_with_two_cards.note_type.card_templates.map(&:ordinal_number).sort
      expect(cards_records_data.map { |hash| hash["mod"] }.sort).to eq note_with_two_cards.cards.map(&:last_modified_timestamp).sort
      expect(cards_records_data.map { |hash| hash["usn"] }).to eq [-1, -1]

      %w[type queue due ivl factor reps lapses left odue odid flags].each do |column|
        expect(cards_records_data.map { |hash| hash[column] }).to eq [0, 0]
      end
      expect(cards_records_data.map { |hash| hash["data"] }).to eq ["{}", "{}"]
    end
    # rubocop:enable RSpec/ExampleLength
  end

  context "when the note is in the collection.anki21 database but has unsaved changes (custom note type, 2 card templates)" do
    subject(:already_saved_note_with_two_cards) do
      note = described_class.new note_type: custom_note_type, deck: default_deck
      note.custom_front = "Hello"
      note.custom_back = "World"
      note.save
      note
    end

    let(:note_count) { anki21_database.prepare("select count(*) from notes;").execute.first["count(*)"] }
    let(:cards_count) { anki21_database.prepare("select count(*) from cards").execute.first["count(*)"] }
    let(:expected_number_of_notes) { 1 }
    let(:expected_number_of_cards) { 2 }
    let(:default_deck) { anki21_database.find_deck_by name: "Default" }
    let(:custom_note_type) do
      custom_note_type = AnkiRecord::NoteType.new anki21_database:, name: "custom note type"
      AnkiRecord::NoteField.new note_type: custom_note_type, name: "custom front"
      AnkiRecord::NoteField.new note_type: custom_note_type, name: "custom back"
      custom_card_template = AnkiRecord::CardTemplate.new note_type: custom_note_type, name: "custom card 1"
      custom_card_template.question_format = "{{custom front}}"
      custom_card_template.answer_format = "{{custom back}}"
      second_custom_card_template = AnkiRecord::CardTemplate.new note_type: custom_note_type, name: "custom card 2"
      second_custom_card_template.question_format = "{{custom back}}"
      second_custom_card_template.answer_format = "{{custom front}}"
      custom_note_type.save
      custom_note_type
    end

    let(:new_custom_front) { "What does the cow say?" }
    let(:new_custom_back) { "Moo" }
    let(:note_record_data) { anki21_database.prepare("select * from notes where id = #{already_saved_note_with_two_cards.id}").execute.first }
    let(:cards_records_data) { anki21_database.prepare("select * from cards where nid = #{already_saved_note_with_two_cards.id}").execute.to_a }

    before do
      already_saved_note_with_two_cards.custom_front = new_custom_front
      already_saved_note_with_two_cards.custom_back = new_custom_back
      already_saved_note_with_two_cards.save
    end

    it "updates the note" do
      expect(note_count).to eq expected_number_of_notes
      expect(note_record_data["flds"]).to eq "#{new_custom_front}\x1F#{new_custom_back}"
      expect(note_record_data["sfld"]).to eq new_custom_front
      expect(cards_count).to eq expected_number_of_cards
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
