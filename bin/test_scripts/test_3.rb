# frozen_string_literal: true

require "anki_record"

FileUtils.rm_f("test_3.apkg")

note_ids = []
AnkiRecord::AnkiPackage.create(name: "test_3") do |anki21_database|
  basic_note_type = anki21_database.find_note_type_by name: "Basic"
  basic_and_reversed_card_note_type = anki21_database.find_note_type_by name: "Basic (and reversed card)"
  basic_and_optional_reversed_card_note_type = anki21_database.find_note_type_by name: "Basic (optional reversed card)"
  basic_type_in_the_answer_note_type = anki21_database.find_note_type_by name: "Basic (type in the answer)"
  cloze_note_type = anki21_database.find_note_type_by name: "Cloze"

  custom_note_type = AnkiRecord::NoteType.new anki21_database:, name: "test 3 custom note type"
  AnkiRecord::NoteField.new note_type: custom_note_type, name: "front"
  AnkiRecord::NoteField.new note_type: custom_note_type, name: "custom back"
  custom_card_template = AnkiRecord::CardTemplate.new note_type: custom_note_type, name: "test 1 card 1"
  custom_card_template.question_format = "{{front}}"
  custom_card_template.answer_format = "{{custom back}}"
  second_custom_card_template = AnkiRecord::CardTemplate.new note_type: custom_note_type, name: "test 1 card 2"
  second_custom_card_template.question_format = "{{custom back}}"
  second_custom_card_template.answer_format = "{{front}}"

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

  custom_deck = AnkiRecord::Deck.new(anki21_database:, name: "test_3_deck")
  custom_deck.save

  5.times do |i|
    note = AnkiRecord::Note.new note_type: basic_note_type, deck: custom_deck
    note.front = "Hello #{i}"
    note.back = "World"
    note.save
    note_ids << note.id
  end

  5.times do |i|
    note = AnkiRecord::Note.new note_type: basic_and_reversed_card_note_type, deck: custom_deck
    note.front = "Hello #{i}"
    note.back = "World"
    note.save
    note_ids << note.id
  end

  5.times do |i|
    note = AnkiRecord::Note.new note_type: basic_and_optional_reversed_card_note_type, deck: custom_deck
    note.front = "Hello #{i}"
    note.back = "World"
    note.add_reverse = "Have a reverse card too"
    note.save
    note_ids << note.id
  end

  5.times do |i|
    note = AnkiRecord::Note.new note_type: basic_type_in_the_answer_note_type, deck: custom_deck
    note.front = "Hello #{i}"
    note.back = "World"
    note.save
    note_ids << note.id
  end
end

AnkiRecord::AnkiPackage.update(path: "./test_3.apkg") do |anki21_database|
  note_ids.each do |note_id|
    note = anki21_database.find_note_by(id: note_id)
    note.front = note.front + " - updated"
    note.save
  end
end
