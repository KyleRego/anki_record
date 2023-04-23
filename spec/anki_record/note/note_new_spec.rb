# frozen_string_literal: true

RSpec.describe AnkiRecord::Note, "#new" do
  after { cleanup_test_files(directory: ".") }

  context "with invalid arguments" do
    let(:anki_package) { AnkiRecord::AnkiPackage.new name: "package_to_test_notes" }
    let(:default_deck) { anki_package.collection.find_deck_by name: "Default" }
    let(:basic_note_type) { anki_package.collection.find_note_type_by name: "Basic" }

    context "when no argument is provided" do
      it "throws an ArgumentError" do
        expect { described_class.new }.to raise_error ArgumentError
      end
    end

    context "when no deck argument is provided with a note_type argument" do
      it "throws an ArgumentError" do
        expect { described_class.new note_type: basic_note_type }.to raise_error ArgumentError
      end
    end

    context "when no note type argument is provided with a deck argument" do
      it "throws an ArgumentError" do
        expect { described_class.new deck: default_deck }.to raise_error ArgumentError
      end
    end

    context "when the note type and deck arguments belong to different collections" do
      it "throws an ArgumentError" do
        second_apkg = AnkiRecord::AnkiPackage.new(name: "second_package")
        second_collection_deck = second_apkg.collection.find_deck_by name: "Default"
        expect { described_class.new note_type: basic_note_type, deck: second_collection_deck }.to raise_error ArgumentError
      end
    end
  end

  context "with valid note_type and deck arguments (new default deck, basic note type note)" do
    subject(:note) { described_class.new deck: default_deck, note_type: basic_note_type }

    let(:anki_package) { AnkiRecord::AnkiPackage.new name: "package_to_test_notes" }
    let(:default_deck) { anki_package.collection.find_deck_by name: "Default" }
    let(:basic_note_type) { anki_package.collection.find_note_type_by name: "Basic" }

    it "instantiates a note" do
      expect(note).to be_a described_class
    end

    it "instantiates a note with collection attribute being an instance of a Collection" do
      expect(note.collection).to be_a AnkiRecord::Collection
    end

    it "instantiates a note with an integer id" do
      expect(note.id).to be_a Integer
    end

    it "instantiates a note with a guid which is a string" do
      expect(note.guid).to be_a String
    end

    it "instantiates a note with a guid which is 10 characters" do
      expect(note.guid.length).to eq 10
    end

    it "instantiates a note with a last_modified_timestamp attribute which is an integer" do
      expect(note.last_modified_timestamp).to be_a Integer
    end

    it "instantiates a note with a tags attribute which is an empty array" do
      expect(note.tags).to eq []
    end

    it "instantiates a note with deck attribute equal to the deck argument" do
      expect(note.deck).to eq default_deck
    end

    it "instantiates a note with note_type attribute equal to the note_type argument" do
      expect(note.note_type).to eq basic_note_type
    end

    it "instantiates a note with a cards attribute with Card objects" do
      expect(note.cards).to all(be_a AnkiRecord::Card)
    end

    it "instantiates a note with a number of card objects equal to the number of card templates of the note type" do
      expect(note.cards.size).to eq note.note_type.card_templates.size
    end
  end

  context "with valid collection and data arguments (existing basic optional reverse note)" do
    subject(:note_from_existing_record) { described_class.new collection: anki_package.collection, data: note_cards_data }

    let(:anki_package) { AnkiRecord::AnkiPackage.new name: "package_to_test_notes" }
    let(:note_cards_data) do
      default_deck = anki_package.collection.find_deck_by name: "Default"
      basic_and_reversed_card_note_type = anki_package.collection.find_note_type_by name: "Basic (and reversed card)"
      note = described_class.new note_type: basic_and_reversed_card_note_type, deck: default_deck
      note.front = "What is the ABC metric?"
      note.back = "A software metric which is a vector of the number of assignments, branches, and conditionals in a method, class, etc."
      note.save

      anki_package.collection.note_cards_data_for_note_id sql_able: anki_package, id: note.id
    end
    let(:note_data) { note_cards_data[:note_data] }
    let(:cards_data) { note_cards_data[:cards_data] }

    it "instantiates a note object" do
      expect(note_from_existing_record).to be_a described_class
    end

    it "instantiates a note object with id attribute equal to the id of the note in the data" do
      expect(note_from_existing_record.id).to eq note_data["id"]
    end

    it "instantiates a note with collection attribute being an instance of a Collection" do
      expect(note_from_existing_record.collection).to be_a AnkiRecord::Collection
    end

    it "instantiates a note object with guid attribute equal to the guid of the note in the data" do
      expect(note_from_existing_record.guid).to eq note_data["guid"]
    end

    it "instantiates a note object with last_modified_timestamp attribute equal to the mod of the note in the data" do
      expect(note_from_existing_record.last_modified_timestamp).to eq note_data["mod"]
    end

    it "instantiates a note object with tags attribute equal to an empty array (because the note has no tags)" do
      expect(note_from_existing_record.tags).to eq []
    end

    it "instantiates a note object with usn attribute equal to the usn of the note in the data" do
      expect(note_from_existing_record.usn).to eq note_data["usn"]
    end

    it "instantiates a note object with field_contents attribute equal to a hash with the names of the fields as keys and contents as values" do
      split_fields = note_data["flds"].split("\x1F")
      expect(note_from_existing_record.field_contents).to eq({ "back" => split_fields[1], "front" => split_fields[0] })
    end

    it "instantiates a note object with flags attribute equal to the flags of the note in the data" do
      expect(note_from_existing_record.flags).to eq note_data["flags"]
    end

    it "instantiates a note object with data attribute equal to the data column value of the note in the data" do
      expect(note_from_existing_record.data).to eq note_data["data"]
    end

    it "instantiates a note object with cards attribute having a length of 2" do
      expect(note_from_existing_record.cards.length).to eq 2
    end

    it "instantiates a note object with two card objects" do
      expect(note_from_existing_record.cards).to all(be_a AnkiRecord::Card)
    end

    it "instantiates a note object with two card objects that has note attribute equal to the note object that is instantiated" do
      note_from_existing_record.cards.each { |card| expect(card.note).to eq note_from_existing_record }
    end

    it "instantiates a note object with two card objects that has card_template attributes with values that are card template objects" do
      note_from_existing_record.cards.each { |card| expect(card.card_template).to be_a AnkiRecord::CardTemplate }
    end

    it "instantiates a note object with two card objects that has card_template attributes with card template object values with ordinal number 0 and 1" do
      expect(note_from_existing_record.cards.map { |card| card.card_template.ordinal_number }.sort).to eq [0, 1]
    end

    it "instantiates a note object with two card objects that has id attributes equal to the ids of the card records in the data" do
      expect(note_from_existing_record.cards.map(&:id)).to eq(cards_data.map { |cd| cd["id"] })
    end

    it "instantiates a note object with two card objects that has last_modified_timestamp attributes equal to the mod values of the card records in the data" do
      expect(note_from_existing_record.cards.map(&:last_modified_timestamp)).to eq(cards_data.map { |cd| cd["mod"] })
    end

    it "instantiates a note object with two card objects that has deck attribute equal to the deck object with id equal to the did of the card records in the data" do
      expect(note_from_existing_record.cards.map(&:deck)).to eq(cards_data.map do |cd|
        note_from_existing_record.collection.find_deck_by id: cd["did"]
      end)
    end

    it "instantiates a note object with two card objects that has usn, type, queue, due, ivl, factor, reps, lapses, left, odue, odid, flags, and data attributes that are equal to these fields with the same name in the cards data" do
      %w[usn type queue due ivl factor reps lapses left odue odid flags data].each do |field|
        expect(note_from_existing_record.cards.map { |card| card.send(field.to_sym) }).to eq(cards_data.map { |cd| cd[field] })
      end
    end
  end
end
