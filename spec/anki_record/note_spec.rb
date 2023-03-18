# frozen_string_literal: true

RSpec.describe AnkiRecord::Note do
  let(:anki_package) { AnkiRecord::AnkiPackage.new name: "package_to_test_notes" }
  let(:basic_note_type) { anki_package.collection.find_note_type_by name: "Basic" }
  let(:basic_and_reversed_card_note_type) do
    anki_package.collection.find_note_type_by name: "Basic (and reversed card)"
  end
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
    context "with valid note_type and deck arguments" do
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
    context "with valid collection and data arguments" do
      context "and the data is from a 'Basic (optional reverse card)' note" do
        before do
          note = AnkiRecord::Note.new note_type: basic_and_reversed_card_note_type, deck: default_deck
          note.front = "What is the ABC metric?"
          note.back = "A software metric which is a vector of the number of assignments, branches, and conditionals in a method, class, etc."
          note.save
          @note_id = note.id
        end
        let(:note_cards_data) { anki_package.collection.note_cards_data_for_note_id sql_able: anki_package, id: @note_id }
        let(:note_data) { note_cards_data[:note_data] }
        subject(:note_from_existing_record) do
          AnkiRecord::Note.new collection: anki_package.collection, data: note_cards_data
        end
        it "should instantiate a note object" do
          expect(note_from_existing_record).to be_a AnkiRecord::Note
        end
        it "should instantiate a note object with id attribute equal to the id of the note in the data" do
          expect(note_from_existing_record.id).to eq note_data["id"]
        end
        it "should instantiate a note object with guid attribute equal to the guid of the note in the data" do
          expect(note_from_existing_record.guid).to eq note_data["guid"]
        end
        it "should instantiate a note object with last_modified_time attribute equal to the mod of the note in the data" do
          expect(note_from_existing_record.last_modified_time).to eq note_data["mod"]
        end
        it "should instantiate a note object with tags attribute equal to an empty array (because the note has no tags)" do
          expect(note_from_existing_record.tags).to eq []
        end
        it "should instantiate a note object with usn attribute equal to the usn of the note in the data" do
          expect(note_from_existing_record.usn).to eq note_data["usn"]
        end
        it "should instantiate a note object with field_contents attribute equal to a hash with the names of the fields as keys and contents as values" do
          split_fields = note_data["flds"].split("\x1F")
          expect(note_from_existing_record.field_contents).to eq({ "back" => split_fields[1], "front" => split_fields[0] })
        end
        it "should instantiate a note object with flags attribute equal to the flags of the note in the data" do
          expect(note_from_existing_record.flags).to eq note_data["flags"]
        end
        it "should instantiate a note object with data attribute equal to the data column value of the note in the data" do
          expect(note_from_existing_record.data).to eq note_data["data"]
        end
        it "should instantiate a note object with cards attribute having a length of 2" do
          expect(note_from_existing_record.cards.length).to eq 2
        end
        it "should instantiate a note object with two card objects" do
          note_from_existing_record.cards.each { |card| expect(card).to be_a AnkiRecord::Card }
        end
        context "should instantiate a note object with two card objects that" do
          let(:cards_data) { note_cards_data[:cards_data] }
          it "should have note attribute equal to the note object that is instantiated" do
            note_from_existing_record.cards.each { |card| expect(card.note).to eq note_from_existing_record }
          end
          it "should have id attributes equal to the ids of the card records in the data" do
            expect(note_from_existing_record.cards.map(&:id)).to eq(cards_data.map { |cd| cd["id"] })
          end
          it "should have last_modified_time attributes equal to the mod values of the card records in the data" do
            expect(note_from_existing_record.cards.map(&:last_modified_time)).to eq(cards_data.map { |cd| cd["mod"] })
          end
          it "should have deck attribute equal to the deck object with id equal to the did of the card records in the data" do
            expect(note_from_existing_record.cards.map(&:deck)).to eq(cards_data.map do |cd|
              note_from_existing_record.collection.find_deck_by id: cd["did"]
            end)
          end
          it "should have usn, type, queue, due, ivl, factor, reps, lapses, left, odue, odid, flags, and data attributes
              that are equal to these fields with the same name in the cards data" do
                %w[usn type queue due ivl factor reps lapses left odue odid flags data].each do |field|
                  expect(note_from_existing_record.cards.map { |card| card.send(field.to_sym) }).to eq(cards_data.map { |cd| cd[field] })
                end
              end
        end
      end
    end
  end

  describe "#save" do
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
    let(:note_record_data) { anki_package.prepare("select * from notes where id = #{note_with_two_cards.id}").execute.first }
    let(:cards_records_data) { anki_package.prepare("select * from cards where nid = #{note_with_two_cards.id}").execute.to_a }
    let(:note_count) { anki_package.prepare("select count(*) from notes;").execute.first["count(*)"] }
    let(:cards_count) { anki_package.prepare("select count(*) from cards").execute.first["count(*)"] }
    let(:expected_number_of_notes) { 1 }
    let(:expected_number_of_cards) { 2 }
    context "for a note with 2 card templates, that does not exist yet in the collection.anki21 database" do
      before { note_with_two_cards.save }
      it "should save a note record to the collection.anki21 database" do
        expect(note_count).to eq expected_number_of_notes
      end
      context "should save a note record to the collection.anki21 database" do
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
        expect(cards_count).to eq expected_number_of_cards
      end
      context "should save two card records to the collection.anki21 database" do
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
    context "for a note with 2 card templates, that does already exist yet the collection.anki21 database, but with unsaved field changes" do
      let(:new_crazy_front) { "What does the cow say?" }
      let(:new_crazy_back) { "moo"}
      subject(:already_saved_note_with_two_cards) do
        already_saved_note_with_two_cards = note_with_two_cards
        already_saved_note_with_two_cards.save
        already_saved_note_with_two_cards.crazy_front = new_crazy_front
        already_saved_note_with_two_cards.crazy_back = new_crazy_back
        already_saved_note_with_two_cards
      end
      before { already_saved_note_with_two_cards.save }
      it "should not change the number of notes in the database" do
        expect(note_count).to eq expected_number_of_notes
      end
      context "should update the already existing note" do
        it "such that the flds value is equal to a string with the two new field values separated by a unit separator" do
          expect(note_record_data["flds"]).to eq "#{new_crazy_front}\x1F#{new_crazy_back}"
        end
        it "such that the sfld value is equal to the sort field, in this case the default, which is the first field" do
          expect(note_record_data["sfld"]).to eq new_crazy_front
        end
      end
      it "should not change the number of cards in the database" do
        expect(cards_count).to eq expected_number_of_cards
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
    context "when the missing method does not end with '=" do
      context "but the method does not correspond to one of the snake_case note type field names"

      context "and the method corresponds to one of the snake_card note type field names"
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
