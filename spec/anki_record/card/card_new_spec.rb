# frozen_string_literal: true

RSpec.describe AnkiRecord::Card, ".new" do
  describe "when passed no arguments" do
    it "throws an ArgumentError" do
      expect { described_class.new }.to raise_error ArgumentError
    end
  end

  describe "when passed a card_template argument but no note argument" do
    subject(:card_instantiated_with_no_note) do
      collection = AnkiRecord::AnkiPackage.new(name: "cards test package").collection
      note_type = AnkiRecord::NoteType.new collection: collection, name: "NOTE_TYPE_A"
      card_template = AnkiRecord::CardTemplate.new note_type: note_type, name: "CARD_TYPE_A"
      described_class.new(card_template: card_template)
    end

    it "throws an ArgumentError" do
      expect { card_instantiated_with_no_note }.to raise_error ArgumentError
    end
  end

  describe "when passed a note argument but no card_template argument" do
    subject(:card_instantiated_with_no_card_template) do
      collection = AnkiRecord::AnkiPackage.new(name: "cards test package").collection
      deck = AnkiRecord::Deck.new(collection: collection, name: "DECK_A")
      note_type = AnkiRecord::NoteType.new collection: collection, name: "NOTE_TYPE_A"
      note = AnkiRecord::Note.new(note_type: note_type, deck: deck)
      described_class.new(note: note)
    end

    it "throws an ArgumentError" do
      expect { card_instantiated_with_no_card_template }.to raise_error ArgumentError
    end
  end

  describe "when passed a card_template argument that belongs to a different note type than the note's" do
    let(:collection) { AnkiRecord::AnkiPackage.new(name: "cards_test_package").anki21_database.collection }
    let(:deck) { AnkiRecord::Deck.new(collection: collection, name: "DECK_A") }
    let(:card_template) do
      note_type = AnkiRecord::NoteType.new collection: collection, name: "NOTE_TYPE_A"
      AnkiRecord::CardTemplate.new note_type: note_type, name: "CARD_TYPE_A"
    end
    let(:other_note) do
      other_note_type = AnkiRecord::NoteType.new collection: collection, name: "Other note type"
      AnkiRecord::Note.new(note_type: other_note_type, deck: deck)
    end

    it "throws an ArgumentError" do
      expect { described_class.new(note: other_note, card_template: card_template) }.to raise_error ArgumentError
    end
  end

  describe "when passed note and card_template arguments" do
    card_new_integration_test = <<-DESC
      1. instantiates a card object
      2. instantiates a card object with note attribute equal to the note object argument
      3. instantiates a card object with deck attribute equal to the deck of the note
      4. instantiates a card object with collection attribute equal to the collection of the card's note's deck's collection
      5. instantiates a card object with card_template attribute equal to the card template argument
      6. instantiates a card object with an integer id attribute
      7. instantiates a card object with an integer last_modified_timestamp attribute
      8. instantiates a card object with an usn attribute equal to -1
      9. instantiates a card object with `type`, `queue`, `due`, `ivl`, `factor`,
        `reps`, `lapses`, `left`, `odue`, `odid`, and `flags` attributes equal to 0
    DESC

    let(:collection) { AnkiRecord::AnkiPackage.new(name: "cards_test_package").anki21_database.collection }
    let(:note_type) { AnkiRecord::NoteType.new collection: collection, name: "NOTE_TYPE_A" }
    let(:card_template) do
      card_template = AnkiRecord::CardTemplate.new note_type: note_type, name: "CARD_TYPE_A"
      AnkiRecord::NoteField.new note_type: note_type, name: "FIELD_A"
      AnkiRecord::NoteField.new note_type: note_type, name: "FIELD_B"
      card_template.question_format = "{{FIELD_A}}\n\n{{FIELD_B}}"
      card_template.answer_format = "{{FrontSide}}\n\n{{FIELD_B}}\n\n{{FIELD_A}}"
      card_template
    end
    let(:note) do
      deck = AnkiRecord::Deck.new(collection: collection, name: "DECK_A")
      AnkiRecord::Note.new(note_type: note_type, deck: deck)
    end
    let(:new_card) { described_class.new(note: note, card_template: card_template) }

    # rubocop:disable RSpec/ExampleLength
    it(card_new_integration_test) do
      # 1
      expect(new_card.instance_of?(described_class)).to be true
      # 2
      expect(new_card.note).to eq note
      # 3
      expect(new_card.deck).to eq note.deck
      # 4
      expect(new_card.collection).to eq note.deck.collection
      # 5
      expect(new_card.card_template).to eq card_template
      # 6
      expect(new_card.id.instance_of?(Integer)).to be true
      # 7
      expect(new_card.last_modified_timestamp.instance_of?(Integer)).to be true
      # 8
      expect(new_card.usn).to eq(-1)
      # 9
      %w[type queue due ivl factor reps lapses left odue odid flags].each do |attribute|
        expect(new_card.send(attribute.to_s)).to eq 0
      end
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
