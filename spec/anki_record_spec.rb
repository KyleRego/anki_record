# frozen_string_literal: true

RSpec.describe AnkiRecord do
  it "is being developed" do
    expect(true).to eq true
  end

  before(:all) { cleanup_test_files directory: "." }

  describe "an unfinished end to end test" do
    it "is an example" do
      note_id = nil
      AnkiRecord::AnkiPackage.new(name: "crazy") do |apkg|
        collection = apkg.collection
        default_deck = collection.find_deck_by name: "Default"
        crazy_note_type = AnkiRecord::NoteType.new collection: collection, name: "crazy note type"
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
        note_id = note.id
      end

      AnkiRecord::AnkiPackage.open(path: "./crazy.apkg") do |apkg|
        collection = apkg.collection
        note = collection.find_note_by id: note_id
        puts "DID NOT FIND NOTE" unless note
        note.crazy_back = "Ruby"
        note.save
      end
    end
  end
end
