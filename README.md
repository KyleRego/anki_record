# Anki Record

Anki Record is a Ruby gem to create and update Anki flashcard deck packages (files with the .apkg extension). It does not support adding media yet.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add anki_record

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install anki_record

## Usage

This example shows how to create a new Anki package and most of the API:

```ruby
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

  # Creating a new note with the custom note type
  note = AnkiRecord::Note.new(note_type: custom_note_type, deck: custom_deck)
  note.custom_front = "Content of the 'custom front' field"
  note.custom_back = "Content of the 'custom back' field"
  note.save

  # Finding the default deck
  default_deck = anki21_database.find_deck_by(name: "Default")

  # Finding all of the default Anki note types
  basic_note_type = anki21_database.find_note_type_by(name: "Basic")
  basic_and_reversed_card_note_type = anki21_database.find_note_type_by(name: "Basic (and reversed card)")
  basic_and_optional_reversed_card_note_type = anki21_database.find_note_type_by(name: "Basic (optional reversed card)")
  basic_type_in_the_answer_note_type = anki21_database.find_note_type_by(name: "Basic (type in the answer)")
  cloze_note_type = anki21_database.find_note_type_by(name: "Cloze")

  # Creating new notes using the default note types

  basic_note = AnkiRecord::Note.new(note_type: basic_note_type, deck: default_deck)
  basic_note.front = "What molecule is most relevant to the name aerobic exercise?"
  basic_note.back = "Oxygen"
  basic_note.save

  # Creating a new nested deck
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
# An example.apkg file should be in the current
# working directory with 6 notes.

```

`AnkiRecord::AnkiPackage.new` can also take a `target_directory` keyword argument to specify the directory to save the Anki package. If an error is thrown inside the block argument, temporary files that exist during execution of the block (Anki SQLite databases and the file called `media`) are deleted and no new Anki package is created.

The gem can also be used to update an existing Anki package:

```ruby
require "anki_record"

AnkiRecord::AnkiPackage.update(path: "./example.apkg") do |anki21_database|
  amino_acids_deck = anki21_database.find_deck_by(name: "Biochemistry::Amino acids")
  custom_note_type = anki21_database.find_note_type_by(name: "New custom note type")

  # Create more decks, note types, notes etc. There are not many methods that would be useful here for finding and updating notes yet.
end
```

If an error is thrown in the block here, the original Anki package will not be changed.

## Documentation

The [API Documentation](https://kylerego.github.io/anki_record_docs) generated from source code comments might be useful but I think the examples above show everything you can do that you would want to do.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

<!-- ## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/KyleRego/anki_record. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/KyleRego/anki_record/blob/master/CODE_OF_CONDUCT.md). -->

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Anki Record project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/KyleRego/anki_record/blob/main/CODE_OF_CONDUCT.md).
