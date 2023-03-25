# frozen_string_literal: true

require "anki_record"

AnkiRecord::AnkiPackage.new(name: "test_0") do |collection|
  basic_note_type = collection.find_note_type_by name: "Basic"
  basic_and_reversed_card_note_type = collection.find_note_type_by name: "Basic (and reversed card)"
  basic_and_optional_reversed_card_note_type = collection.find_note_type_by name: "Basic (optional reversed card)"
  basic_type_in_the_answer_note_type = collection.find_note_type_by name: "Basic (type in the answer)"
  cloze_note_type = collection.find_note_type_by name: "Cloze"
  default_deck = collection.find_deck_by name: "Default"

  5.times do |i|
    note = AnkiRecord::Note.new note_type: basic_note_type, deck: default_deck
    note.front = "Hello #{i}"
    note.back = "World"
    note.save
  end

  5.times do |i|
    note = AnkiRecord::Note.new note_type: basic_and_reversed_card_note_type, deck: default_deck
    note.front = "Hello #{i}"
    note.back = "World"
    note.save
  end

  5.times do |i|
    note = AnkiRecord::Note.new note_type: basic_and_optional_reversed_card_note_type, deck: default_deck
    note.front = "Hello #{i}"
    note.back = "World"
    note.add_reverse = "Have a reverse card too"
    note.save
  end

  5.times do |i|
    note = AnkiRecord::Note.new note_type: basic_type_in_the_answer_note_type, deck: default_deck
    note.front = "Hello #{i}"
    note.back = "World"
    note.save
  end

  5.times do |i|
    note = AnkiRecord::Note.new note_type: cloze_note_type, deck: default_deck
    note.text = "Cloze {{c1::Hello}} #{i}"
    note.back_extra = "World"
    note.save
  end
end
