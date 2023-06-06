# frozen_string_literal: true

require "anki_record"

# This is a load test to see if the primary key id uniqueness constraint can be
# violated by the way it is computed, which is an integer time since the epoch.

FileUtils.rm_f("test_2.apkg")

start_time = Time.now
AnkiRecord::AnkiPackage.new(name: "test_2") do |anki21_database|
  basic_note_type = anki21_database.find_note_type_by name: "Basic"
  basic_and_reversed_card_note_type = anki21_database.find_note_type_by name: "Basic (and reversed card)"
  basic_and_optional_reversed_card_note_type = anki21_database.find_note_type_by name: "Basic (optional reversed card)"
  basic_type_in_the_answer_note_type = anki21_database.find_note_type_by name: "Basic (type in the answer)"
  cloze_note_type = anki21_database.find_note_type_by name: "Cloze"
  custom_deck = AnkiRecord::Deck.new(anki21_database:, name: "test_2_deck")
  custom_deck.save

  1000.times do |i|
    note = AnkiRecord::Note.new note_type: basic_note_type, deck: custom_deck
    note.front = "Hello #{i}"
    note.back = "World"
    note.save
  end

  1000.times do |i|
    note = AnkiRecord::Note.new note_type: basic_and_reversed_card_note_type, deck: custom_deck
    note.front = "Hello #{i}"
    note.back = "World"
    note.save
  end

  1000.times do |i|
    note = AnkiRecord::Note.new note_type: basic_and_optional_reversed_card_note_type, deck: custom_deck
    note.front = "Hello #{i}"
    note.back = "World"
    note.add_reverse = "Have a reverse card too"
    note.save
  end

  1000.times do |i|
    note = AnkiRecord::Note.new note_type: basic_type_in_the_answer_note_type, deck: custom_deck
    note.front = "Hello #{i}"
    note.back = "World"
    note.save
  end

  1000.times do |i|
    note = AnkiRecord::Note.new note_type: cloze_note_type, deck: custom_deck
    note.text = "Cloze {{c1::Hello}} #{i}"
    note.back_extra = "World"
    note.save
  end
end
end_time = Time.now
time_diff_seconds = (end_time - start_time).to_i

puts "Test 2 took #{time_diff_seconds} seconds"
