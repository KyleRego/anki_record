# frozen_string_literal: true

RSpec.describe AnkiRecord::Collection do
  subject(:collection) { AnkiRecord::Collection.new(anki_package: anki_package) }

  after { cleanup_test_files(directory: ".") }

  context "when the AnkiPackage represents a new empty *.apkg file created using this library" do
    let(:anki_package) { AnkiRecord::AnkiPackage.new(name: "package_to_test_collection") }

    describe "::new" do
      it "should instantiate a new Collection object" do
        expect(collection.instance_of?(AnkiRecord::Collection)).to eq true
      end
      it "should instantiate a new Collection object with anki_package attribute which is the AnkiPackage object argument" do
        expect(collection.anki_package).to eq anki_package
      end
      it "should instantiate a new Collection object with an id of 1" do
        expect(collection.id).to eq 1
      end
      it "should instantiate a new Collection object with the creation_timestamp attribute having an integer value" do
        expect(collection.creation_timestamp.instance_of?(Integer)).to eq true
      end
      it "should instantiate a new Collection object with a last_modified_time attribute having the value 0" do
        expect(collection.last_modified_time).to eq 0
      end
      it "should instantiate a new Collection object with 5 note types" do
        expect(collection.note_types.count).to eq 5
      end
      it "should instantiate a new Collection object with the 5 default note types" do
        default_note_type_names_array = ["Basic", "Basic (and reversed card)", "Basic (optional reversed card)", "Basic (type in the answer)", "Cloze"]
        expect(collection.note_types.map(&:name).sort).to eq default_note_type_names_array
      end
      it "should instantiate a new Collection object with note_types that are all instances of NoteType" do
        expect(collection.note_types.all? { |note_type| note_type.instance_of?(AnkiRecord::NoteType) }).to eq true
      end
      it "should instantiate a new Collection object with 1 deck" do
        expect(collection.decks.count).to eq 1
      end
      it "should instantiate a new Collection object with a deck called 'Default'" do
        expect(collection.decks.first.name).to eq "Default"
      end
      it "should instantiate a new Collection object with decks that are all instances of Deck" do
        expect(collection.decks.all? { |deck| deck.instance_of?(AnkiRecord::Deck) }).to eq true
      end
      it "should instantiate a new Collection object with 1 deck options group" do
        expect(collection.deck_options_groups.count).to eq 1
      end
      it "should instantiate a new Collection object with a deck options group called 'Default'" do
        expect(collection.deck_options_groups.first.name).to eq "Default"
      end
      it "should instantiate a new Collection object with deck_options_groups that are all instances of DeckOptionsGroup" do
        expect(collection.deck_options_groups.all? { |deck_opts| deck_opts.instance_of?(AnkiRecord::DeckOptionsGroup) }).to eq true
      end
    end

    describe "#find_note_type_by" do
      context "when passed both name and id arguments" do
        it "should throw an ArgumentError" do
          expect { collection.find_note_type_by(name: "name", id: "id") }.to raise_error ArgumentError
        end
      end
      context "when passed neither a name nor an id argument" do
        it "should throw an ArgumentError" do
          expect { collection.find_note_type_by }.to raise_error ArgumentError
        end
      end
      context "when passed a name argument where the collection does not have a note type with that name" do
        it "should return nil" do
          expect(collection.find_note_type_by(name: "no-note-type-with-this-name")).to eq nil
        end
      end
      context "when passed a name argument where the collection has a note type with that name" do
        it "should return a note type object" do
          expect(collection.find_note_type_by(name: "Basic").instance_of?(AnkiRecord::NoteType)).to eq true
        end
        it "should return a note type object with name equal to the name argument" do
          expect(collection.find_note_type_by(name: "Basic").name).to eq "Basic"
        end
      end
      context "when passed an id argument where the collection does not have a note type with that id" do
        it "should return nil" do
          expect(collection.find_note_type_by(id: "1234")).to eq nil
        end
      end
      context "when passed an id argument where the collection has a note type with that id" do
        let(:basic_note_type_id) { collection.find_note_type_by(name: "Basic").id }
        it "should return a note type object" do
          expect(collection.find_note_type_by(id: basic_note_type_id).instance_of?(AnkiRecord::NoteType)).to eq true
        end
        it "should return a note type object with name equal to the name argument" do
          expect(collection.find_note_type_by(id: basic_note_type_id).id).to eq basic_note_type_id
        end
      end
    end

    describe "#find_deck_by" do
      context "when passed both name and id arguments" do
        it "should throw an ArgumentError" do
          expect { collection.find_deck_by(name: "name", id: "id") }.to raise_error ArgumentError
        end
      end
      context "when passed neither a name nor an id argument" do
        it "should throw an ArgumentError" do
          expect { collection.find_deck_by }.to raise_error ArgumentError
        end
      end
      context "when passed a name argument where the collection does not have a deck with that name" do
        it "should return nil" do
          expect(collection.find_deck_by(name: "no-deck-with-this-name")).to eq nil
        end
      end
      context "when passed a name argument where the collection has a deck with that name" do
        it "should return a deck object" do
          expect(collection.find_deck_by(name: "Default")).to be_a AnkiRecord::Deck
        end
        it "should return a deck object with name equal to the name argument" do
          expect(collection.find_deck_by(name: "Default").name).to eq "Default"
        end
      end
      context "when passed an id argument where the collection does not have a note type with that id" do
        it "should return nil" do
          expect(collection.find_deck_by(id: "1234")).to eq nil
        end
      end
      context "when passed an id argument where the collection has a deck with that id" do
        let(:default_deck_id) { collection.find_deck_by(name: "Default").id }
        it "should return a note type object" do
          expect(collection.find_deck_by(id: default_deck_id).instance_of?(AnkiRecord::Deck)).to eq true
        end
        it "should return a note type object with name equal to the name argument" do
          expect(collection.find_deck_by(id: default_deck_id).id).to eq default_deck_id
        end
      end
    end

    describe "#find_note_by" do
      context "when passed an id argument where the collection does not have a note with that id" do
        it "should return nil" do
          expect(collection.find_note_by(id: "1234")).to eq nil
        end
      end
      context "when passed an id argument where the collection does have a note with that id" do
        context "and there is a Basic note type note with that id" do
          before do
            apkg = AnkiRecord::AnkiPackage.new(name: "package_with_a_note")
            @collection = apkg.collection
            basic_note_type = @collection.find_note_type_by name: "Basic"
            default_deck = @collection.find_deck_by name: "Default"
            @note = AnkiRecord::Note.new deck: default_deck, note_type: basic_note_type
            @note.save
          end
          it "should return a note object" do
            expect(@collection.find_note_by(id: @note.id)).to be_a AnkiRecord::Note
          end
          it "should return a note object with one card"
          it "should return a note object with id equal to the id argument" do
            expect(@collection.find_note_by(id: @note.id).id).to eq @note.id
          end
          it "should return a note object with one card equal to the id of the note's corresponding card record"
        end
      end
    end
  end
end
