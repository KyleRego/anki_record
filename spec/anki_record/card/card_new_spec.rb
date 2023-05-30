# frozen_string_literal: true

require "./spec/anki_record/support/clean_slate_anki_package"

RSpec.describe AnkiRecord::Card, ".new" do
  include_context "when the anki package is a clean slate"

  it "throws an ArgumentError when passed no arguments" do
    expect { described_class.new }.to raise_error ArgumentError
  end

  describe "when passed a card_template but no note" do
    subject(:card_with_no_note) do
      note_type = AnkiRecord::NoteType.new collection: collection, name: "NOTE_TYPE_A"
      card_template = AnkiRecord::CardTemplate.new note_type: note_type, name: "CARD_TYPE_A"
      described_class.new(card_template: card_template)
    end

    it "throws an ArgumentError" do
      expect { card_with_no_note }.to raise_error ArgumentError
    end
  end

  describe "when passed a note but no card_template" do
    subject(:card_with_no_template) do
      deck = AnkiRecord::Deck.new(collection: collection, name: "DECK_A")
      note_type = AnkiRecord::NoteType.new collection: collection, name: "NOTE_TYPE_A"
      note = AnkiRecord::Note.new(note_type: note_type, deck: deck)
      described_class.new(note: note)
    end

    it "throws an ArgumentError" do
      expect { card_with_no_template }.to raise_error ArgumentError
    end
  end

  describe "when passed a card_template that belongs to a different note type than the note's" do
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
    it "instantiates a card belonging to the note and using the card_template" do
      expect(new_card.instance_of?(described_class)).to be true
      expect(new_card.note).to eq note
      expect(new_card.deck).to eq note.deck
      expect(new_card.collection).to eq note.deck.collection
      expect(new_card.card_template).to eq card_template
      expect(new_card.id.instance_of?(Integer)).to be true
      expect(new_card.last_modified_timestamp.instance_of?(Integer)).to be true
      expect(new_card.usn).to eq(-1)
      %w[type queue due ivl factor reps lapses left odue odid flags].each do |attribute|
        expect(new_card.send(attribute.to_s)).to eq 0
      end
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
