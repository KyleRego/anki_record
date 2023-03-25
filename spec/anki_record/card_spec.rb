# frozen_string_literal: true

RSpec.describe AnkiRecord::Card do
  describe "::new passed no arguments" do
    it "should throw an ArgumentError" do
      expect { AnkiRecord::Card.new }.to raise_error ArgumentError
    end
  end

  describe "::new passed a card_template argument but no note argument" do
    subject(:card_instantiated_with_no_note) do
      collection = AnkiRecord::AnkiPackage.new(name: "cards test package").collection
      note_type = AnkiRecord::NoteType.new collection: collection, name: "NOTE_TYPE_A"
      card_template = AnkiRecord::CardTemplate.new note_type: note_type, name: "CARD_TYPE_A"
      AnkiRecord::Card.new(card_template: card_template)
    end
    it "should throw an ArgumentError" do
      expect { card_instantiated_with_no_note }.to raise_error ArgumentError
    end
  end

  describe "::new passed a note argument but no card_template argument" do
    subject(:card_instantiated_with_no_card_template) do
      collection = AnkiRecord::AnkiPackage.new(name: "cards test package").collection
      deck = AnkiRecord::Deck.new(collection: collection, name: "DECK_A")
      note_type = AnkiRecord::NoteType.new collection: collection, name: "NOTE_TYPE_A"
      note = AnkiRecord::Note.new(note_type: note_type, deck: deck)
      AnkiRecord::Card.new(note: note)
    end
    it "should throw an ArgumentError" do
      expect { card_instantiated_with_no_card_template }.to raise_error ArgumentError
    end
  end

  describe "::new when passed a card_template argument that belongs to a different note type than the note's" do
    it "should throw an ArgumentError" do
      collection = AnkiRecord::AnkiPackage.new(name: "cards_test_package").collection
      deck = AnkiRecord::Deck.new(collection: collection, name: "DECK_A")
      note_type = AnkiRecord::NoteType.new collection: collection, name: "NOTE_TYPE_A"
      card_template = AnkiRecord::CardTemplate.new note_type: note_type, name: "CARD_TYPE_A"
      other_note_type = AnkiRecord::NoteType.new collection: collection, name: "Other note type"
      other_note = AnkiRecord::Note.new(note_type: other_note_type, deck: deck)
      expect { AnkiRecord::Card.new(note: other_note, card_template: card_template) }.to raise_error ArgumentError
    end
  end

  describe "::new when passed note and card_template arguments" do
    before(:all) do
      collection = AnkiRecord::AnkiPackage.new(name: "cards_test_package").collection
      note_type = AnkiRecord::NoteType.new collection: collection, name: "NOTE_TYPE_A"
      @card_template = AnkiRecord::CardTemplate.new note_type: note_type, name: "CARD_TYPE_A"
      AnkiRecord::NoteField.new note_type: note_type, name: "FIELD_A"
      AnkiRecord::NoteField.new note_type: note_type, name: "FIELD_B"
      @card_template.question_format = "{{FIELD_A}}\n\n{{FIELD_B}}"
      @card_template.answer_format = "{{FrontSide}}\n\n{{FIELD_B}}\n\n{{FIELD_A}}"

      deck = AnkiRecord::Deck.new(collection: collection, name: "DECK_A")
      @note = AnkiRecord::Note.new(note_type: note_type, deck: deck)
      @new_card = AnkiRecord::Card.new(note: @note, card_template: @card_template)
    end
    it "should instantiate a card object" do
      expect(@new_card.instance_of?(AnkiRecord::Card)).to eq true
    end
    it "should instantiate a card object with note attribute equal to the note object argument" do
      expect(@new_card.note).to eq @note
    end
    it "should instantiate a card object with deck attribute equal to the deck of the note" do
      expect(@new_card.deck).to eq @note.deck
    end
    it "should instantiate a card object with collection attribute equal to the collection of the card's note's deck's collection" do
      expect(@new_card.collection).to eq @note.deck.collection
    end
    it "should instantiate a card object with card_template attribute equal to the card template argument" do
      expect(@new_card.card_template).to eq @card_template
    end
    it "should instantiate a card object with an integer id attribute" do
      expect(@new_card.id.instance_of?(Integer)).to eq true
    end
    it "should instantiate a card object with an integer last_modified_timestamp attribute" do
      expect(@new_card.last_modified_timestamp.instance_of?(Integer)).to eq true
    end
    it "should instantiate a card object with an usn attribute equal to -1" do
      expect(@new_card.usn).to eq(-1)
    end
    it "should instantiate a card object with `type`, `queue`, `due`, `ivl`, `factor`,
        `reps`, `lapses`, `left`, `odue`, `odid`, and `flags` attributes equal to 0" do
      %w[type queue due ivl factor reps lapses left odue odid flags].each do |attribute|
        expect(@new_card.send(attribute.to_s)).to eq 0
      end
    end
  end
end
