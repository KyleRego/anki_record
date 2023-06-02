# frozen_string_literal: true

require "anki_record"

FileUtils.rm_f("test_0.apkg")

apkg = AnkiRecord::AnkiPackage.new(name: "test_0")
collection = apkg.anki21_database.collection
custom_nested_deck = AnkiRecord::Deck.new(name: "parent::child::nested_deck::super nested", collection:)
custom_nested_deck.save
basic_note_type = collection.find_note_type_by name: "Basic"
note = AnkiRecord::Note.new(deck: custom_nested_deck, note_type: basic_note_type)
note.front = "Hello from test_0"
note.back = "World"
note.save
apkg.zip
