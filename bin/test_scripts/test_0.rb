# frozen_string_literal: true

require "anki_record"

FileUtils.rm_f("test_0.apkg")

apkg = AnkiRecord::AnkiPackage.create(name: "test_0")
anki21_database = apkg.anki21_database
custom_nested_deck = AnkiRecord::Deck.new(name: "test_0_parent::child::nested_deck::super nested", anki21_database:)
custom_nested_deck.save
basic_note_type = anki21_database.find_note_type_by name: "Basic"
note = AnkiRecord::Note.new(deck: custom_nested_deck, note_type: basic_note_type)
note.front = "Hello from test_0"
note.back = "World"
note.save
apkg.zip
