# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
# rubocop:disable Layout/LineLength

require "anki_record"

AnkiRecord::AnkiPackage.create(name: "example") do |anki21_database|
  # Creating a new deck
  custom_deck = AnkiRecord::Deck.new(anki21_database:, name: "New custom deck")
  custom_deck.save

  # Creating a new note type
  custom_note_type = AnkiRecord::NoteType.new(anki21_database:,
                                              name: "New custom note type")
  AnkiRecord::NoteField.new(note_type: custom_note_type,
                            name: "custom front")
  AnkiRecord::NoteField.new(note_type: custom_note_type,
                            name: "custom back")
  custom_card_template = AnkiRecord::CardTemplate.new(note_type: custom_note_type,
                                                      name: "Custom template 1")
  custom_card_template.question_format = "{{custom front}}"
  custom_card_template.answer_format = "{{custom back}}"
  second_custom_card_template = AnkiRecord::CardTemplate.new(note_type: custom_note_type,
                                                             name: "Custom template 2")
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

  # Creating a note with the custom note type
  note = AnkiRecord::Note.new(note_type: custom_note_type, deck: custom_deck)
  note.custom_front = "Content of the 'custom front' field"
  note.custom_back = "Content of the 'custom back' field"
  note.save

  # The default deck
  default_deck = anki21_database.find_deck_by(name: "Default")

  # All of the default Anki note types
  basic_note_type = anki21_database.find_note_type_by(name: "Basic")
  basic_and_reversed_card_note_type = anki21_database.find_note_type_by(name: "Basic (and reversed card)")
  basic_and_optional_reversed_card_note_type = anki21_database.find_note_type_by(name: "Basic (optional reversed card)")
  basic_type_in_the_answer_note_type = anki21_database.find_note_type_by(name: "Basic (type in the answer)")
  cloze_note_type = anki21_database.find_note_type_by(name: "Cloze")

  # Creating notes using the default note types

  basic_note = AnkiRecord::Note.new(note_type: basic_note_type, deck: default_deck)
  basic_note.front = "What molecule is most relevant to the name aerobic exercise?"
  basic_note.back = "Oxygen"
  basic_note.save

  # Creating a nested deck
  amino_acids_deck = AnkiRecord::Deck.new(anki21_database:,
                                          name: "Biochemistry::Amino acids")
  amino_acids_deck.save

  basic_and_reversed_note = AnkiRecord::Note.new(note_type: basic_and_reversed_card_note_type,
                                                 deck: amino_acids_deck)
  basic_and_reversed_note.front = "Tyrosine"
  basic_and_reversed_note.back = "Y"
  basic_and_reversed_note.save

  basic_and_optional_reversed_note = AnkiRecord::Note.new(note_type: basic_and_optional_reversed_card_note_type,
                                                          deck: default_deck)
  basic_and_optional_reversed_note.front = "A technique where locations along a route are memorized and associated with ideas"
  basic_and_optional_reversed_note.back = "The method of loci"
  basic_and_optional_reversed_note.add_reverse = "Have a reverse card too"
  basic_and_optional_reversed_note.save

  basic_type_in_the_answer_note = AnkiRecord::Note.new(note_type: basic_type_in_the_answer_note_type,
                                                       deck: default_deck)
  basic_type_in_the_answer_note.front = "What Git command commits staged changes by changing the previous commit without editing the commit message?"
  basic_type_in_the_answer_note.back = "git commit --amend --no-edit"
  basic_type_in_the_answer_note.save

  cloze_note = AnkiRecord::Note.new(note_type: cloze_note_type, deck: default_deck)
  cloze_note.text = "Dysfunction of CN {{c1::VII}} occurs in Bell's palsy"
  cloze_note.back_extra = "This condition involves one cranial nerve but can have myriad neurological symptoms"
  cloze_note.save
end
# The example.apkg package now exists in the current
# working directory and contains 6 notes.

# rubocop:enable Metrics/BlockLength
# rubocop:enable Layout/LineLength
