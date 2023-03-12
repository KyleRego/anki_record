# frozen_string_literal: true

RSpec.describe AnkiRecord::Card do
  let(:collection_argument) do
    anki_package = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
    AnkiRecord::Collection.new(anki_package: anki_package)
  end
  let(:note_type_argument) do
    note_type = AnkiRecord::NoteType.new collection: collection_argument, name: "NOTE_TYPE_A"
    card_template = AnkiRecord::CardTemplate.new note_type: note_type, name: "CARD_TYPE_A"
    AnkiRecord::NoteField.new note_type: note_type, name: "FIELD_A"
    AnkiRecord::NoteField.new note_type: note_type, name: "FIELD_B"
    card_template.question_format = "{{FIELD_A}}\n\n{{FIELD_B}}"
    card_template.answer_format = "{{FrontSide}}\n\n{{FIELD_B}}\n\n{{FIELD_A}}"
    note_type
  end
  let(:deck_argument) { AnkiRecord::Deck.new(collection: collection_argument, name: "DECK_A") }
  let(:note_argument) { AnkiRecord::Note.new(note_type: note_type_argument, deck: deck_argument) }
  let(:card_template_argument) { note_argument.note_type.find_card_template_by(name: "CARD_TYPE_A") }
  subject(:new_card) do
    AnkiRecord::Card.new note: note_argument, card_template: card_template_argument
  end

  describe "::new" do
    context "with invalid arguments" do
      context "when neither the note nor the card template arguments are given" do
        it "should throw an ArgumentError" do
          expect { AnkiRecord::Card.new }.to raise_error ArgumentError
        end
      end
      context "when the note argument is not given" do
        it "should throw an ArgumentError" do
          expect { AnkiRecord::Card.new(card_template: card_template_argument) }.to raise_error ArgumentError
        end
      end
      context "when the card template argument is not given" do
        it "should throw an ArgumentError" do
          expect { AnkiRecord::Card.new(note: note_argument) }.to raise_error ArgumentError
        end
      end
      context "when the card template belongs to a different note type than the note's note type" do
        it "should throw an ArgumentError" do
          other_note_type = AnkiRecord::NoteType.new collection: collection_argument, name: "Other note type"
          other_note = AnkiRecord::Note.new(note_type: other_note_type, deck: deck_argument)
          expect { AnkiRecord::Card.new(note: other_note, card_template: card_template_argument) }.to raise_error ArgumentError
        end
      end
    end
    context "with valid note and card_template arguments" do
      it "should instantiate a card object" do
        expect(new_card.instance_of?(AnkiRecord::Card)).to eq true
      end
      it "should instantiate a card object with note attribute equal to the note object argument" do
        expect(new_card.note).to eq note_argument
      end
      it "should instantiate a card object with deck attribute equal to the deck of the note" do
        expect(new_card.deck).to eq note_argument.deck
      end
      it "should instantiate a card object with collection attribute equal to the collection of the card's note's deck's collection" do
        expect(new_card.collection).to eq note_argument.deck.collection
      end
      it "should instantiate a card object with card_template attribute equal to the card template argument" do
        expect(new_card.card_template).to eq card_template_argument
      end
      it "should instantiate a card object with an integer id attribute" do
        expect(new_card.id.instance_of?(Integer)).to eq true
      end
      it "should instantiate a card object with an integer last_modified_time attribute" do
        expect(new_card.last_modified_time.instance_of?(Integer)).to eq true
      end
      it "should instantiate a card object with an usn attribute equal to -1" do
        expect(new_card.usn).to eq(-1)
      end
      it "should instantiate a card object with `type`, `queue`, `due`, `ivl`, `factor`,
          `reps`, `lapses`, `left`, `odue`, `odid`, and `flags` attributes equal to 0" do
        %w[type queue due ivl factor reps lapses left odue odid flags].each do |attribute|
          expect(new_card.send(attribute.to_s)).to eq 0
        end
      end
    end
    context "with valid note and card_templates arguments and the card_data argument with an already existing card data hash" do
      let(:card_data_hash) do
        { "id" => 1_678_650_585_538,
          "nid" => 1_678_650_580_123,
          "did" => 1,
          "ord" => 0,
          "mod" => 1_678_650_583,
          "usn" => -1,
          "type" => 0,
          "queue" => 0,
          "due" => 0,
          "ivl" => 0,
          "factor" => 0,
          "reps" => 0,
          "lapses" => 0,
          "left" => 0,
          "odue" => 0,
          "odid" => 0,
          "flags" => 0,
          "data" => "{}" }
      end
    end
  end
end
