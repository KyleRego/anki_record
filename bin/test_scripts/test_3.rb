# frozen_string_literal: true

require "anki_record"

# This test is really the result of me doing some experiments, trying to figure out
# what Anki uses to match a note being imported to one that already exists to update it,
# rather than create a duplicate. It turned out to be the guid from what I can tell.

FileUtils.rm_f("test_3a.apkg")

note_ids = []

AnkiRecord::AnkiPackage.new(name: "test_3a") do |collection|
  basic_note_type = collection.find_note_type_by name: "Basic"
  default_deck = collection.find_deck_by name: "Default"

  10.times do |i|
    note = AnkiRecord::Note.new note_type: basic_note_type, deck: default_deck
    note.front = "Hello #{i}"
    note.back = "World"
    note.save
    note_ids << note.guid
  end
end

FileUtils.rm_f("test_3b.apkg")

AnkiRecord::AnkiPackage.new(name: "test_3b") do |collection|
  basic_note_type = collection.find_note_type_by name: "Basic"
  default_deck = collection.find_deck_by name: "Default"

  note_ids.each do |note_id|
    puts note_id
    note = AnkiRecord::Note.new note_type: basic_note_type, deck: default_deck
    note.front = "Hello world #{note_id}"
    note.back = "World"
    note.guid = note_id
    note.save
  end
end
