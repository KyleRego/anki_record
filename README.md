# Anki Record

Anki Record is a Ruby library which provides a programmatic interface to Anki flashcard decks (`*.apkg` files, or Anki SQLite databases). **It is in an early stage of development and the API is not stable. I do not recommend you try it yet.**

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add anki_record

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install anki_record

## Documentation

The usage section following this one should have examples showing the most common use cases, but the gem also has some additional documentation.

The [API Documentation](https://kylerego.github.io/anki_record_docs) is generated using RDoc from comments in the source code. You might notice that some public methods are intentionally omitted from this documentation. Although public, these methods are not intended to be used outside of the gem's implementation and should be treated as private.

The RSpec examples are intended to provide executable documentation and may also be helpful to understand the API. Running the test suite with the `rspec` command will output this in a way that reflects the nesting of the RSpec examples and example groups. The test suite files should have a 1-to-1 mapping with the source code files.

## Usage

The Anki package object is instantiated with `AnkiRecord::AnkiPackage.new`. If this is passed a block, it will execute the block, and afterwards zip an `*.apkg` file where `*` is the name argument (this argument is not allowed to contain spaces):

```ruby
require "anki_record"

AnkiRecord::AnkiPackage.new(name: "test") do |apkg|
  3.times do |number|
    puts "#{3 - number}..."
  end
  puts "Countdown complete. Write any Ruby you want in here!"
end
# test.apkg now exists in the current working directory.
```

While execution is happening inside the block, temporary `collection.anki21` and `collection.anki2` SQLite databases and a `media` file exist inside of a temporary directory. These files are the normal zipped contents of an `*.apkg` file. `collection.anki21` is the database that the library is interacting with.

If an exception is raised inside the block, the files are deleted without creating a new `*.apkg` zip file, so this is the recommended way.

Alternatively, if `AnkiRecord::Package::new` is not passed a block, the `zip` method must be explicitly called on the Anki package object:

```ruby
require "anki_record"

apkg = AnkiRecord::AnkiPackage.new(name: "test")
apkg.zip # This zips the temporary files into test.apkg, and then deletes them.
```

A new Anki package object is initialized with the "Default" deck and the default note types of a new Anki collection (including "Basic" and "Cloze"). The deck and note type objects are accessed through the `collection` attribute of the Anki package object through the `find_deck_by` and `find_note_type_by` methods passed the `name` keyword argument:

```ruby
require "anki_record"

apkg = AnkiRecord::AnkiPackage.new name: "test"

deck = apkg.collection.find_deck_by name: "Default"

note_type = apkg.collection.find_note_type_by name: "Basic"

note = AnkiRecord::Note.new note_type: note_type, deck: deck
note.front = "Hello"
note.back = "World"
note.save

note_type2 = apkg.collection.find_note_type_by name: "Cloze"

note2 = AnkiRecord::Note.new note_type: note_type2, deck: deck
note2.text = "Cloze {{c1::Hello}}"
note2.back_extra = "World"
note2.save

apkg.zip

```

This example creates a `test.apkg` zip file in the current working directory, which when imported into Anki, will add one Basic note and one Cloze note.

The following example is from the next version of the library which is unreleased.

```ruby
require "anki_record"

AnkiRecord::AnkiPackage.new(name: "crazy") do |apkg|
  collection = apkg.collection
  default_deck = collection.find_deck_by name: "Default"
  crazy_note_type = AnkiRecord::NoteType.new collection: collection, name: "crazy note type"
  AnkiRecord::NoteField.new note_type: crazy_note_type, name: "crazy front"
  AnkiRecord::NoteField.new note_type: crazy_note_type, name: "crazy back"
  crazy_card_template = AnkiRecord::CardTemplate.new note_type: crazy_note_type, name: "crazy card 1"
  crazy_card_template.question_format = "{{crazy front}}"
  crazy_card_template.answer_format = "{{crazy back}}"
  second_crazy_card_template = AnkiRecord::CardTemplate.new note_type: crazy_note_type, name: "crazy card 2"
  second_crazy_card_template.question_format = "{{crazy back}}"
  second_crazy_card_template.answer_format = "{{crazy front}}"
  crazy_note_type.save

  note = AnkiRecord::Note.new note_type: crazy_note_type, deck: default_deck
  note.crazy_front = "Hello"
  note.crazy_back = "World"
  note.save
end
```

This creates `crazy.apkg` with a new custom note type called "crazy note type" and one note using it.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Development road map:
- CSS of crazy note type example and other setters
- Saving notes of a custom type
- Updating notes when they already exist in the database
- Saving note types, decks, and deck options groups to the collection.anki21 database
  - And updating them when they already exist
- Setters for attributes of the note types, decks, and deck options groups
- Refactor to use only parameterized SQL statements
- Work on creating, updating, and saving notes and cards to the collection.anki21 database
- Validation logic of what makes the note valid based on the note type's card templates and fields
- Work on adding media support
  - The checksum calculation for notes will need to be updated to account for HTML in the content
- Specs need to be refactored to be more DRY and also start using doubles to improve performance

### Release checklist
- Update changelog
- Update usage examples
- Update and regenerate documentation
- Bump version
- Release gem

<!-- ## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/KyleRego/anki_record. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/KyleRego/anki_record/blob/master/CODE_OF_CONDUCT.md). -->

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Anki Record project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/KyleRego/anki_record/blob/main/CODE_OF_CONDUCT.md).
