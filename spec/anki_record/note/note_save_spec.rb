# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"

# TODO: Refactor to not use one expect per example
RSpec.describe AnkiRecord::Note, "#save" do
  include_context "when the anki package is a clean slate"

  after { cleanup_test_files(directory: ".") }

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  context "when the note that does not exist in the collection.anki21 database (custom note type, 2 card templates)" do
    subject!(:note_with_two_cards) do
      note = described_class.new note_type: custom_note_type, deck: default_deck
      note.custom_front = "Hello"
      note.custom_back = "World"
      note.save
      note
    end

    let(:default_deck) { collection.find_deck_by name: "Default" }
    let(:custom_note_type) do
      custom_note_type = AnkiRecord::NoteType.new collection: collection, name: "custom note type"
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

    let(:note_record_data) { collection.anki21_database.prepare("select * from notes where id = #{note_with_two_cards.id}").execute.first }
    let(:cards_records_data) { collection.anki21_database.prepare("select * from cards where nid = #{note_with_two_cards.id}").execute.to_a }
    let(:note_count) { collection.anki21_database.prepare("select count(*) from notes;").execute.first["count(*)"] }
    let(:cards_count) { collection.anki21_database.prepare("select count(*) from cards").execute.first["count(*)"] }
    let(:expected_number_of_notes) { 1 }
    let(:expected_number_of_cards) { 2 }

    it "saves a note record to the collection.anki21 database" do
      expect(note_count).to eq expected_number_of_notes
    end

    it "saves a note record to the collection.anki21 database with an id value equal to the id of the note object" do
      expect(note_record_data["id"]).to eq note_with_two_cards.id
    end

    it "saves a note record to the collection.anki21 database with a guid value equal to the guid attribute of the note object" do
      expect(note_record_data["guid"]).to eq note_with_two_cards.guid
    end

    it "saves a note record to the collection.anki21 database with an mid value equal to the id of the note's note type's id" do
      expect(note_record_data["mid"]).to eq note_with_two_cards.note_type.id
    end

    it "saves a note record to the collection.anki21 database with an mod value equal to the last_modified_timestamp attribute of the note object" do
      expect(note_record_data["mod"]).to eq note_with_two_cards.last_modified_timestamp
    end

    it "saves a note record to the collection.anki21 database with an usn value equal to -1" do
      expect(note_record_data["usn"]).to eq(-1)
    end

    it "saves a note record to the collection.anki21 databasewith a tags value equal to an empty string" do
      expect(note_record_data["tags"]).to eq ""
    end

    it "saves a note record to the collection.anki21 database with a flds value equal to a string with the two field values separated by a unit separator" do
      expect(note_record_data["flds"]).to eq "Hello\x1FWorld"
    end

    it "saves a note record to the collection.anki21 database with a sfld value equal to the sort field, in this case the default, which is the first field" do
      expect(note_record_data["sfld"]).to eq "Hello"
    end

    it "saves a note record to the collection.anki21 database with a csum value being an integer with 10 digits (see Helpers::ChecksumHelper)" do
      expect(note_record_data["csum"].to_s.length).to eq 10
    end

    it "saves a note record to the collection.anki21 database with a flags value being 0" do
      expect(note_record_data["flags"]).to eq 0
    end

    it "saves a note record to the collection.anki21 database with a data value being an empty string" do
      expect(note_record_data["data"]).to eq ""
    end

    it "saves two card records to the collection.anki21 database" do
      expect(cards_count).to eq expected_number_of_cards
    end

    it "saves two card records to the collection.anki21 database with id values equal to the ids of the card objects" do
      expect(cards_records_data.map { |hash| hash["id"] }.sort).to eq note_with_two_cards.cards.map(&:id).sort
    end

    it "saves two card records to the collection.anki21 database with nid values equal to the id of the cards' note object's id" do
      expect(cards_records_data.map { |hash| hash["nid"] }).to eq [note_with_two_cards.id] * 2
    end

    it "saves two card records to the collection.anki21 database with did values equal to the id of the cards' note object's deck" do
      expect(cards_records_data.map { |hash| hash["did"] }).to eq [note_with_two_cards.deck.id] * 2
    end

    it "saves two card records to the collection.anki21 database with ord values equal to the ordinal_number attributes of the corresponding card templates" do
      expect(cards_records_data.map { |hash| hash["ord"] }.sort).to eq note_with_two_cards.note_type.card_templates.map(&:ordinal_number).sort
    end

    it "saves two card records to the collection.anki21 database with mod values equal to the last_modified_timestamp attributes of the card objects" do
      expect(cards_records_data.map { |hash| hash["mod"] }.sort).to eq note_with_two_cards.cards.map(&:last_modified_timestamp).sort
    end

    it "saves two card records to the collection.anki21 database with usn values equal to -1" do
      expect(cards_records_data.map { |hash| hash["usn"] }).to eq [-1, -1]
    end

    it "saves two card records to the collection.anki21 database with type, queue, due, ivl. factor, reps, lapses, left, odue, odid, and flags values equal to 0" do
      %w[type queue due ivl factor reps lapses left odue odid flags].each do |column|
        expect(cards_records_data.map { |hash| hash[column] }).to eq [0, 0]
      end
    end

    it "saves two card records to the collection.anki21 database with data values equal to '{}'" do
      expect(cards_records_data.map { |hash| hash["data"] }).to eq ["{}", "{}"]
    end
  end

  context "when the note is in the collection.anki21 database but has unsaved changes (custom note type, 2 card templates)" do
    subject(:already_saved_note_with_two_cards) do
      note = described_class.new note_type: custom_note_type, deck: default_deck
      note.custom_front = "Hello"
      note.custom_back = "World"
      note.save
      note
    end

    let(:collection) do
      AnkiRecord::AnkiPackage.new(name: "package_to_test_notes").anki21_database.collection
    end
    let(:note_count) { collection.anki21_database.prepare("select count(*) from notes;").execute.first["count(*)"] }
    let(:cards_count) { collection.anki21_database.prepare("select count(*) from cards").execute.first["count(*)"] }
    let(:expected_number_of_notes) { 1 }
    let(:expected_number_of_cards) { 2 }
    let(:default_deck) { collection.find_deck_by name: "Default" }
    let(:custom_note_type) do
      custom_note_type = AnkiRecord::NoteType.new collection: collection, name: "custom note type"
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
    let(:note_record_data) { collection.anki21_database.prepare("select * from notes where id = #{already_saved_note_with_two_cards.id}").execute.first }
    let(:cards_records_data) { collection.anki21_database.prepare("select * from cards where nid = #{already_saved_note_with_two_cards.id}").execute.to_a }

    before do
      already_saved_note_with_two_cards.custom_front = new_custom_front
      already_saved_note_with_two_cards.custom_back = new_custom_back
      already_saved_note_with_two_cards.save
    end

    it "doesn't change the number of notes in the database" do
      expect(note_count).to eq expected_number_of_notes
    end

    it "updates the already existing note such that the flds value is equal to a string with the two new field values separated by a unit separator" do
      expect(note_record_data["flds"]).to eq "#{new_custom_front}\x1F#{new_custom_back}"
    end

    it "updates the already existing note such that the sfld value is equal to the sort field, in this case the default, which is the first field" do
      expect(note_record_data["sfld"]).to eq new_custom_front
    end

    it "doesn't change the number of cards in the database" do
      expect(cards_count).to eq expected_number_of_cards
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
