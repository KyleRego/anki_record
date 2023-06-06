# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"

# TODO: Refactor to not use one expect per example
RSpec.describe AnkiRecord::Note, "#new" do
  include_context "when the anki package is a clean slate"

  context "with invalid arguments" do
    let(:default_deck) { anki21_database.find_deck_by name: "Default" }
    let(:basic_note_type) { anki21_database.find_note_type_by name: "Basic" }

    it "throws an error when passed no arguments" do
      expect { described_class.new }.to raise_error ArgumentError
    end

    it "throws an error a note_type is passed but a deck is not" do
      expect { described_class.new note_type: basic_note_type }.to raise_error ArgumentError
    end

    it "throws an error a deck is passed but a note_type is not" do
      expect { described_class.new deck: default_deck }.to raise_error ArgumentError
    end

    it "throws an error when passed note_type and deck that belong to different Anki databases" do
      anki_package2 = AnkiRecord::AnkiPackage.new(name: "second_package")
      other_package_deck = anki_package2.anki21_database.find_deck_by name: "Default"
      expect { described_class.new note_type: basic_note_type, deck: other_package_deck }.to raise_error ArgumentError
    end
  end

  context "when passed a valid note_type and deck" do
    subject(:note) { described_class.new deck: default_deck, note_type: basic_note_type }

    let(:default_deck) { anki21_database.find_deck_by name: "Default" }
    let(:basic_note_type) { anki21_database.find_note_type_by name: "Basic" }

    # rubocop:disable RSpec/ExampleLength
    it "instantiates a note of that type and belonging to the deck" do
      expect(note).to be_a described_class
      expect(note.anki21_database).to be_a AnkiRecord::Anki21Database
      expect(note.id).to be_a Integer
      expect(note.guid).to be_a String
      expect(note.guid.length).to eq 10
      expect(note.last_modified_timestamp).to be_a Integer
      expect(note.tags).to eq []
      expect(note.deck).to eq default_deck
      expect(note.note_type).to eq basic_note_type
      expect(note.cards).to all(be_a AnkiRecord::Card)
      expect(note.cards.size).to eq note.note_type.card_templates.size
    end
    # rubocop:enable RSpec/ExampleLength
  end

  context "when passed an anki21_database and an existing note's raw data (existing basic optional reverse note)" do
    subject(:note_from_existing_record) { described_class.new anki21_database:, data: note_cards_data }

    let(:note_cards_data) do
      default_deck = anki21_database.find_deck_by name: "Default"
      basic_and_reversed_card_note_type = anki21_database.find_note_type_by name: "Basic (and reversed card)"
      note = described_class.new note_type: basic_and_reversed_card_note_type, deck: default_deck
      note.front = "What is the ABC metric?"
      note.back = "A software metric which is a vector of the number of assignments, branches, and conditionals in a method, class, etc."
      note.save

      anki21_database.send(:note_cards_data_for_note_id, id: note.id)
    end
    let(:note_data) { note_cards_data[:note_data] }
    let(:cards_data) { note_cards_data[:cards_data] }

    # rubocop:disable RSpec/ExampleLength
    it "instantiates a note and card collaborators from the raw data" do
      expect(note_from_existing_record).to be_a described_class
      expect(note_from_existing_record.id).to eq note_data["id"]
      expect(note_from_existing_record.anki21_database).to be_a AnkiRecord::Anki21Database
      expect(note_from_existing_record.guid).to eq note_data["guid"]
      expect(note_from_existing_record.last_modified_timestamp).to eq note_data["mod"]
      expect(note_from_existing_record.tags).to eq []
      expect(note_from_existing_record.usn).to eq note_data["usn"]

      split_fields = note_data["flds"].split("\x1F")
      expect(note_from_existing_record.field_contents).to eq({ "back" => split_fields[1], "front" => split_fields[0] })

      expect(note_from_existing_record.flags).to eq note_data["flags"]
      expect(note_from_existing_record.data).to eq note_data["data"]
      expect(note_from_existing_record.cards.length).to eq 2
      expect(note_from_existing_record.cards).to all(be_a AnkiRecord::Card)
      note_from_existing_record.cards.each do |card|
        expect(card.note).to eq note_from_existing_record
        expect(card.card_template).to be_a AnkiRecord::CardTemplate
      end
      expect(note_from_existing_record.cards.map { |card| card.card_template.ordinal_number }.sort).to eq [0, 1]
      expect(note_from_existing_record.cards.map(&:id)).to eq(cards_data.map { |cd| cd["id"] })
      expect(note_from_existing_record.cards.map(&:last_modified_timestamp)).to eq(cards_data.map { |cd| cd["mod"] })
      expect(note_from_existing_record.cards.map(&:deck)).to eq(cards_data.map do |cd|
        note_from_existing_record.anki21_database.find_deck_by id: cd["did"]
      end)

      %w[usn type queue due ivl factor reps lapses left odue odid flags data].each do |field|
        expect(note_from_existing_record.cards.map { |card| card.send(field.to_sym) }).to eq(cards_data.map { |cd| cd[field] })
      end
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
