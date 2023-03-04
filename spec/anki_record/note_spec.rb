# frozen_string_literal: true

RSpec.describe AnkiRecord::Note do
  let(:anki_package) { AnkiRecord::AnkiPackage.new(name: "package_to_test_notes") }
  let(:basic_note_type) { anki_package.collection.find_note_type_by name: "Basic" }
  let(:default_deck) { anki_package.collection.find_deck_by name: "Default" }

  subject(:note) { AnkiRecord::Note.new deck: default_deck, note_type: basic_note_type }

  describe "::new" do
    context "with invalid arguments" do
      context "when neither the deck nor the note type argument is provided" do
        it "should throw an ArgumentError" do
          expect { AnkiRecord::Note.new }.to raise_error ArgumentError
        end
      end
      context "when no deck argument is provided" do
        it "should throw an ArgumentError" do
          expect { AnkiRecord::Note.new note_type: basic_note_type }.to raise_error ArgumentError
        end
      end
      context "when no note type argument is provided" do
        it "should throw an ArgumentError" do
          expect { AnkiRecord::Note.new deck: default_deck }.to raise_error ArgumentError
        end
      end
      context "when the note type and deck belong to different collections" do
        it "should throw an ArgumentError" do
          second_apkg = AnkiRecord::AnkiPackage.new(name: "second_package")
          second_collection_deck = second_apkg.collection.find_deck_by name: "Default"
          expect { AnkiRecord::Note.new note_type: basic_note_type, deck: second_collection_deck }.to raise_error ArgumentError
        end
      end
    end
    it "should instantiate a note" do
      expect(note.instance_of?(AnkiRecord::Note)).to eq true
    end
    it "should instantiate a note with an integer id" do
      expect(note.id.instance_of?(Integer)).to eq true
    end
    it "should instantiate a note with a guid which is a string" do
      expect(note.guid.instance_of?(String)).to eq true
    end
    it "should instantiate a note with a guid which is 10 characters" do
      expect(note.guid.length).to eq 10
    end
    it "should instantiate a note with a last_modified_time attribute which is an integer" do
      expect(note.last_modified_time.instance_of?(Integer)).to eq true
    end
    it "should instantiate a note with a tags attribute which is an empty array" do
      expect(note.tags).to eq []
    end
    it "should instantiate a note with deck attribute equal to the deck argument" do
      expect(note.deck).to eq default_deck
    end
    it "should instantiate a note with note_type attribute equal to the note_type argument" do
      expect(note.note_type).to eq basic_note_type
    end
    it "should instantiate a note with a cards attribute with Card objects" do
      expect(note.cards.all? { |card| card.instance_of?(AnkiRecord::Card) }).to eq true
    end
    it "should instantiate a note with a number of card objects equal to the number of card templates of the note type" do
      expect(note.cards.size).to eq note.note_type.card_templates.size
    end
  end

  describe "#method_missing" do
    context "when the missing method ends with '='" do
      context "but the method does not correspond to one of the snake_case note type field names" do
        it "should throw an error" do
          expect { note.made_up_field = "Made up" }.to raise_error ArgumentError
        end
      end
      context "and the method corresponds to one of the snake_case note type field names" do
        it "should set that field" do
          note.front = "Content of the note Front field"
          expect(note.front).to eq "Content of the note Front field"
        end
      end
    end
  end

  describe "#respond_to_missing?" do
    context "when the missing method ends with '='" do
      context "when the method corresponds to one of the snake_case note type field names" do
        it "should return true" do
          expect(note.respond_to?(:front=)).to eq true
        end
      end
      context "when the method does not correspond to one of the snake_case note type field names" do
        it "should return false" do
          expect(note.respond_to?(:made_up=)).to eq false
        end
      end
    end
    context "when the missing method does not end with =" do
      context "when the missing method corresponds to one of the snake_case note type field names" do
        it "should return true" do
          expect(note.respond_to?(:front)).to eq true
        end
      end
      context "when the missing method does not correspond to one of the snake_case note type field names" do
        it "should return false" do
          expect(note.respond_to?(:made_up)).to eq false
        end
      end
    end
  end
end
