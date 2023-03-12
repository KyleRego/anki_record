# frozen_string_literal: true

RSpec.describe AnkiRecord::Note do
  let(:anki_package) { AnkiRecord::AnkiPackage.new name: "package_to_test_notes" }
  let(:basic_note_type) { anki_package.collection.find_note_type_by name: "Basic" }
  let(:default_deck) { anki_package.collection.find_deck_by name: "Default" }

  subject(:note) { AnkiRecord::Note.new deck: default_deck, note_type: basic_note_type }

  describe "::new" do
    context "with invalid arguments" do
      context "when no argument is provided" do
        it "should throw an ArgumentError" do
          expect { AnkiRecord::Note.new }.to raise_error ArgumentError
        end
      end
      context "when no deck argument is provided with a note_type argument" do
        it "should throw an ArgumentError" do
          expect { AnkiRecord::Note.new note_type: basic_note_type }.to raise_error ArgumentError
        end
      end
      context "when no note type argument is provided with a deck argument" do
        it "should throw an ArgumentError" do
          expect { AnkiRecord::Note.new deck: default_deck }.to raise_error ArgumentError
        end
      end
      context "when the note type and deck arguments belong to different collections" do
        it "should throw an ArgumentError" do
          second_apkg = AnkiRecord::AnkiPackage.new(name: "second_package")
          second_collection_deck = second_apkg.collection.find_deck_by name: "Default"
          expect { AnkiRecord::Note.new note_type: basic_note_type, deck: second_collection_deck }.to raise_error ArgumentError
        end
      end
    end
    context "when passed valid note_type and deck arguments" do
      it "should instantiate a note" do
        expect(note).to be_a AnkiRecord::Note
      end
      it "should instantiate a note with an integer id" do
        expect(note.id).to be_a Integer
      end
      it "should instantiate a note with a guid which is a string" do
        expect(note.guid).to be_a String
      end
      it "should instantiate a note with a guid which is 10 characters" do
        expect(note.guid.length).to eq 10
      end
      it "should instantiate a note with a last_modified_time attribute which is an integer" do
        expect(note.last_modified_time).to be_a Integer
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
        note.cards.each { |card| expect(card).to be_a AnkiRecord::Card }
      end
      it "should instantiate a note with a number of card objects equal to the number of card templates of the note type" do
        expect(note.cards.size).to eq note.note_type.card_templates.size
      end
    end
  end

  describe "#save" do
    context "for a note with 2 card templates" do
      subject(:note_with_two_cards) do
        crazy_note_type = AnkiRecord::NoteType.new collection: anki_package.collection, name: "crazy note type"
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
        note
      end
      before { note_with_two_cards.save }
      it "should save a note record to the collection.anki21 database" do
        expect(anki_package.execute("select count(*) from notes;").first["count(*)"]).to eq 1
      end
      context "should save a note record to the collection.anki21 database" do
        let(:note_record_data) { anki_package.execute("select * from notes;").first }
        it "with an id value equal to the id of the note object" do
          expect(note_record_data["id"]).to eq note_with_two_cards.id
        end
        it "with a guid value equal to the guid attribute of the note object" do
          expect(note_record_data["guid"]).to eq note_with_two_cards.guid
        end
        it "with an mid value equal to the id of the note's note type's id" do
          expect(note_record_data["mid"]).to eq note_with_two_cards.note_type.id
        end
        it "with an mod value equal to the last_modified_time attribute of the note object" do
          expect(note_record_data["mod"]).to eq note_with_two_cards.last_modified_time
        end
        it "with an usn value equal to -1" do
          expect(note_record_data["usn"]).to eq(-1)
        end
        it "with a tags value equal to an empty string" do
          expect(note_record_data["tags"]).to eq ""
        end
        it "with a flds value equal to a string with the two field values separated by a unit separator" do
          expect(note_record_data["flds"]).to eq "Hello\x1FWorld"
        end
        it "with a sfld value equal to the sort field, in this case the default, which is the first field" do
          expect(note_record_data["sfld"]).to eq "Hello"
        end
        it "with a csum value being an integer with 10 digits (see ChecksumHelper)" do
          expect(note_record_data["csum"].to_s.length).to eq 10
        end
        it "with a flags value being 0" do
          expect(note_record_data["flags"]).to eq 0
        end
        it "with a data value being an empty string" do
          expect(note_record_data["data"]).to eq ""
        end
      end
      it "should save two card records to the collection.anki21 database" do
        expect(anki_package.execute("select count(*) from cards;").first["count(*)"]).to eq 2
      end
      context "should save two card records to the collection.anki21 database" do
        let(:cards_records_data) { anki_package.execute("select * from cards;") }
        it "with id values equal to the ids of the card objects" do
          expect(cards_records_data.map { |hash| hash["id"] }.sort).to eq note_with_two_cards.cards.map(&:id).sort
        end
        it "with nid values equal to the id of the cards' note object's id" do
          expect(cards_records_data.map { |hash| hash["nid"] }).to eq [note_with_two_cards.id] * 2
        end
        it "with did values equal to the id of the cards' note object's deck" do
          expect(cards_records_data.map { |hash| hash["did"] }).to eq [note_with_two_cards.deck.id] * 2
        end
        it "with ord values equal to the ordinal_number attributes of the corresponding card templates" do
          expect(cards_records_data.map { |hash| hash["ord"] }.sort).to eq note_with_two_cards.note_type.card_templates.map(&:ordinal_number).sort
        end
        it "with mod values equal to the last_modified_time attributes of the card objects" do
          expect(cards_records_data.map { |hash| hash["mod"] }.sort).to eq note_with_two_cards.cards.map(&:last_modified_time).sort
        end
        it "with usn values equal to -1" do
          expect(cards_records_data.map { |hash| hash["usn"] }).to eq [-1, -1]
        end
        it "with type, queue, due, ivl. factor, reps, lapses, left, odue, odid, and flags values equal to 0" do
          %w[type queue due ivl factor reps lapses left odue odid flags].each do |column|
            expect(cards_records_data.map { |hash| hash[column] }).to eq [0, 0]
          end
        end
        it "with data values equal to '{}'" do
          expect(cards_records_data.map { |hash| hash["data"] }).to eq ["{}", "{}"]
        end
      end
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
