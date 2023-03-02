# frozen_string_literal: true

RSpec.describe AnkiRecord do
  it "is being developed" do
    expect(true).to eq true
  end

  before(:all) { cleanup_test_files directory: "." }

  context "end to end tests" do
    describe "::new and ::open without block arguments" do
      # it "should zip a new, empty Anki package (test1.apkg)
      #     and then it should open that file and zip an updated version (test1-number.apkg)
      #     and both of these should import into Anki correctly" do
      #   apkg = AnkiRecord::AnkiPackage.new name: "test1"
      #   apkg.zip
      #   apkg2 = AnkiRecord::AnkiPackage.open path: "test1.apkg"
      #   apkg2.zip
      # end

      it "should zip a new, empty Anki package (test2.apkg) with 2 Basic notes in the Default deck",
         skip: "this API is unimplemented" do
        apkg = AnkiRecord::AnkiPackage.new name: "test2"

        note_type = apkg.collection.find_note_type_by name: "Basic"
        # or note_type = apkg.collection.find_note_type_by id: 1

        deck = apkg.collection.find_deck_by name: "Default"
        # or deck = apkg.collection.find_deck_by id: 1

        note = AnkiRecord::Note.new note_type: note_type, deck: deck, front: "Hello world", back: ""
        note.save
        # or
        note2 = AnkiRecord::Note.new note_type: note_type, deck: deck
        note2.front = "Hello world"
        note2.back = ""
        note2.save

        apkg.zip
      end
    end
  end
end
