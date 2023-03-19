# frozen_string_literal: true

RSpec.describe AnkiRecord::Collection do
  subject(:collection) { AnkiRecord::Collection.new(anki_package: anki_package) }

  after { cleanup_test_files(directory: ".") }

  context "when the AnkiPackage represents a new empty *.apkg file created using this library" do
    let(:anki_package) { AnkiRecord::AnkiPackage.new(name: "package_to_test_collection") }

    describe "::new" do
      it "should instantiate a new Collection object" do
        expect(collection).to be_a AnkiRecord::Collection
      end
      it "should instantiate a new Collection object with anki_package attribute which is the AnkiPackage object argument" do
        expect(collection.anki_package).to eq anki_package
      end
      it "should instantiate a new Collection object with an id of 1" do
        expect(collection.id).to eq 1
      end
      it "should instantiate a new Collection object with the created_at_timestamp attribute having an integer value" do
        expect(collection.created_at_timestamp).to be_a Integer
      end
      it "should instantiate a new Collection object with a last_modified_timestamp attribute having the value 0" do
        expect(collection.last_modified_timestamp).to eq 0
      end
      it "should instantiate a new Collection object with 5 note types" do
        expect(collection.note_types.count).to eq 5
      end
      it "should instantiate a new Collection object with the 5 default note types" do
        default_note_type_names_array = ["Basic", "Basic (and reversed card)", "Basic (optional reversed card)", "Basic (type in the answer)", "Cloze"]
        expect(collection.note_types.map(&:name).sort).to eq default_note_type_names_array
      end
      it "should instantiate a new Collection object with note_types that are all instances of NoteType" do
        collection.note_types.all? { |note_type| expect(note_type).to be_a AnkiRecord::NoteType }
      end
      it "should instantiate a new Collection object with 1 deck" do
        expect(collection.decks.count).to eq 1
      end
      it "should instantiate a new Collection object with a deck called 'Default'" do
        expect(collection.decks.first.name).to eq "Default"
      end
      it "should instantiate a new Collection object with decks that are all instances of Deck" do
        collection.decks.all? { |deck| expect(deck).to be_a AnkiRecord::Deck }
      end
      it "should instantiate a new Collection object with 1 deck options group" do
        expect(collection.deck_options_groups.count).to eq 1
      end
      it "should instantiate a new Collection object with a deck options group called 'Default'" do
        expect(collection.deck_options_groups.first.name).to eq "Default"
      end
      it "should instantiate a new Collection object with deck_options_groups that are all instances of DeckOptionsGroup" do
        collection.deck_options_groups.all? { |deck_opts| expect(deck_opts).to be_a AnkiRecord::DeckOptionsGroup }
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
      context "when the note type exists in the opened Anki package but not the current collection.anki21 database" do
        let(:opened_apkg_name) { "crazy" }
        let(:path_argument) { "./#{opened_apkg_name}.apkg" }
        let(:note_type_name) { "crazy note type" }
        before do
          AnkiRecord::AnkiPackage.new(name: opened_apkg_name) do |collection|
            default_deck = collection.find_deck_by name: "Default"
            crazy_note_type = AnkiRecord::NoteType.new collection: collection, name: note_type_name
            AnkiRecord::NoteField.new note_type: crazy_note_type, name: "crazy front"
            AnkiRecord::NoteField.new note_type: crazy_note_type, name: "crazy back"
            crazy_card_template = AnkiRecord::CardTemplate.new note_type: crazy_note_type, name: "crazy card 1"
            crazy_card_template.question_format = "{{crazy front}}"
            crazy_card_template.answer_format = "{{crazy back}}"
            second_crazy_card_template = AnkiRecord::CardTemplate.new note_type: crazy_note_type, name: "crazy card 2"
            second_crazy_card_template.question_format = "{{crazy back}}"
            second_crazy_card_template.answer_format = "{{crazy front}}"
            crazy_note_type.save

            note = AnkiRecord::Note.new note_type: crazy_note_type, deck: default_deck
            note.crazy_front = "Hello"
            note.crazy_back = "World"
            note.save
            @note_type_id = crazy_note_type.id
            @note_id = note.id
          end
        end
        let(:copied_over_collection) do
          apkg = AnkiRecord::AnkiPackage.open(path: path_argument)
          apkg.collection
        end
        it "should return a note type" do
          expect(copied_over_collection.find_note_type_by(name: note_type_name))
        end
        it "should return a note type with the same id as the existing note type from the opened package" do
          expect(copied_over_collection.find_note_type_by(name: note_type_name).id).to eq @note_type_id
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
          expect(collection.find_deck_by(id: default_deck_id)).to be_a AnkiRecord::Deck
        end
        it "should return a note type object with name equal to the name argument" do
          expect(collection.find_deck_by(id: default_deck_id).id).to eq default_deck_id
        end
      end
    end

    describe "#find_deck_options_group_by" do
      context "when passed an id argument where the collection does not have a note type with that id" do
        it "should return nil" do
          expect(collection.find_deck_options_group_by(id: "1234")).to eq nil
        end
      end
      context "when passed an id argument where the collection has a deck with that id" do
        let(:default_deck_options_group_id) { collection.find_deck_by(name: "Default").deck_options_group.id }
        it "should return a note type object" do
          expect(collection.find_deck_options_group_by(id: default_deck_options_group_id)).to be_a AnkiRecord::DeckOptionsGroup
        end
        it "should return a note type object with name equal to the name argument" do
          expect(collection.find_deck_by(id: default_deck_options_group_id).id).to eq default_deck_options_group_id
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
        context "and it is a Basic note type note" do
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
          it "should return a note object with id equal to the id argument" do
            expect(@collection.find_note_by(id: @note.id).id).to eq @note.id
          end
          it "should return a note object with one card" do
            expect(@collection.find_note_by(id: @note.id).cards.count).to eq 1
          end
          it "should return a note object with one card equal to the id of the note's corresponding card record" do
            expect(@collection.find_note_by(id: @note.id).cards.first.id).to eq @note.cards.first.id
          end
        end
      end
    end

    describe "#add_note_type" do
      it "should throw an error if the argument object is not an instance of NoteType" do
        expect { collection.add_note_type("bad object") }.to raise_error ArgumentError
      end
    end

    describe "#add_deck" do
      it "should throw an error if the argument object is not an instance of Deck" do
        expect { collection.add_deck("bad object") }.to raise_error ArgumentError
      end
    end

    describe "#add_deck_options_group" do
      it "should throw an error if the argument object is not an instance of DeckOptionsGroup" do
        expect { collection.add_deck_options_group("bad object") }.to raise_error ArgumentError
      end
    end
  end
end
