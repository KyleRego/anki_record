# frozen_string_literal: true

require "anki_record"

FileUtils.rm_f("test_1.apkg")

AnkiRecord::AnkiPackage.new(name: "test_1") do |anki21_database|
  collection = anki21_database.collection
  custom_deck = AnkiRecord::Deck.new collection: collection, name: "test_1_deck"
  custom_deck.save
  custom_note_type = AnkiRecord::NoteType.new collection: collection, name: "test 1 note type"
  AnkiRecord::NoteField.new note_type: custom_note_type, name: "custom front"
  AnkiRecord::NoteField.new note_type: custom_note_type, name: "custom back"
  custom_card_template = AnkiRecord::CardTemplate.new note_type: custom_note_type, name: "test 1 card 1"
  custom_card_template.question_format = "{{custom front}}"
  custom_card_template.answer_format = "{{custom back}}"
  second_custom_card_template = AnkiRecord::CardTemplate.new note_type: custom_note_type, name: "test 1 card 2"
  second_custom_card_template.question_format = "{{custom back}}"
  second_custom_card_template.answer_format = "{{custom front}}"

  css = <<~CSS
    .card {
      font-size: 16px;
      font-style: Verdana;
      background: transparent;
      text-align: center;
    }
  CSS

  custom_note_type.css = css
  custom_note_type.save

  note = AnkiRecord::Note.new note_type: custom_note_type, deck: custom_deck
  note.custom_front = "Hello from test 1"
  note.custom_back = "World"
  note.save
  note_id = note.id

  note = anki21_database.find_note_by id: note_id
  note.custom_back = "Ruby"
  note.save
end
