require "anki_record"

AnkiRecord::AnkiPackage.update(path: "./example.apkg") do |anki21_database|
  amino_acids_deck = anki21_database.find_deck_by(name: "Biochemistry::Amino acids")
  custom_note_type = anki21_database.find_note_type_by(name: "New custom note type")

  # Create more decks, note types, etc. The API for updating is not completely fleshed out yet.
end
