# Anki Record

Anki Record is a Ruby gem providing an API to Anki flashcard deck packages (zipped SQLite databases). The main thing it does not support yet is adding media to the notes.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add anki_record

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install anki_record

## Usage

The Anki package object is instantiated with `AnkiRecord::AnkiPackage.new`. If this is passed a block, the collection object is yielded to the block, and an Anki deck package file is created after execution of the block:

```ruby
require "anki_record"

AnkiRecord::AnkiPackage.new(name: "test") do |collection|
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
collection = apkg.collection
# Add notes to the collection
apkg.zip # This zips the temporary files into test.apkg, and then deletes them.
```

The second, optional argument to `AnkiRecord::AnkiPackage.new` is `target_directory`. The default value is the current working directory, but if a relative file path argument is given, the new `*.apkg` file will be saved in that directory. An exception will be raised if the relative file path is not to a directory that exists.

A new Anki package object is initialized with the "Default" deck and the default note types of a new Anki collection (including "Basic" and "Cloze"). The deck and note type objects are accessed through the `collection` attribute of the Anki package object through the `find_deck_by` and `find_note_type_by` methods passed the `name` keyword argument:

```ruby
require "anki_record"

AnkiRecord::AnkiPackage.new(name: "test") do |collection|
  deck = collection.find_deck_by name: "Default"

  note_type = collection.find_note_type_by name: "Basic"

  note = AnkiRecord::Note.new note_type: note_type, deck: deck
  note.front = "Hello"
  note.back = "World"
  note.save

  note_type2 = collection.find_note_type_by name: "Cloze"

  note2 = AnkiRecord::Note.new note_type: note_type2, deck: deck
  note2.text = "Cloze {{c1::Hello}}"
  note2.back_extra = "World"
  note2.save
end

```

This example creates a `test.apkg` zip file in the current working directory, which when imported into Anki, will add one Basic note and one Cloze note.

The next example shows some other features of the library:

```ruby
require "anki_record"

note_id = nil

AnkiRecord::AnkiPackage.new(name: "test_1") do |collection|
  crazy_deck = AnkiRecord::Deck.new collection: collection, name: "test_1_deck"
  crazy_deck.save

  crazy_note_type = AnkiRecord::NoteType.new collection: collection, name: "test 1 note type"
  AnkiRecord::NoteField.new note_type: crazy_note_type, name: "crazy front"
  AnkiRecord::NoteField.new note_type: crazy_note_type, name: "crazy back"
  crazy_card_template = AnkiRecord::CardTemplate.new note_type: crazy_note_type, name: "test 1 card 1"
  crazy_card_template.question_format = "{{crazy front}}"
  crazy_card_template.answer_format = "{{crazy back}}"
  second_crazy_card_template = AnkiRecord::CardTemplate.new note_type: crazy_note_type, name: "test 1 card 2"
  second_crazy_card_template.question_format = "{{crazy back}}"
  second_crazy_card_template.answer_format = "{{crazy front}}"

  css = <<~CSS
    .card {
      font-size: 16px;
      font-style: Verdana;
      background: transparent;
      text-align: center;
    }
  CSS

  crazy_note_type.css = css
  crazy_note_type.save

  note = AnkiRecord::Note.new note_type: crazy_note_type, deck: crazy_deck
  note.crazy_front = "Hello from test 1"
  note.crazy_back = "World"
  note.save

  note_id = note.id
end

AnkiRecord::AnkiPackage.open(path: "./test_1.apkg") do |collection|
  note = collection.find_note_by id: note_id
  note.crazy_back = "Ruby"
  note.save
end
```

This script creates an Anki package `test_1.apkg` with a new deck and new note type, and one note in that deck using that type. It then opens that Anki package, and edits the note. Note that the `test_1.apkg` file is not changed by this. Instead, a new package with a name similar to `test_1-1679835468.apkg` is created (the number is a timestamp).

## Documentation

The [API Documentation](https://kylerego.github.io/anki_record_docs) is generated using SDoc from comments in the source code. You might notice that some public methods are intentionally omitted from this documentation. Although public, these methods are not intended to be used outside of the gem's implementation and should be treated as private.

The RSpec examples are intended to provide executable documentation and may also be helpful to understand the API. Running the test suite with the `rspec` command will output these in a more readable way that also reflects the nesting of the RSpec examples and example groups. This is an example of part of the output:

```
AnkiRecord::Deck#save
  when the deck does not exist in the collection.anki21 database
    saves the deck object's id as a key in the decks column's JSON object in the collection.anki21 database
    saves the deck object as a hash, as the value of the deck object's id key, in the decks hash
    saves the deck object as a hash with the following keys: 'id', 'mod', 'name', 'usn', 'lrnToday', 'revToday', 'newToday', 'timeToday', 'collapsed', 'browserCollapsed', 'desc', 'dyn', 'conf', 'extendNew', 'extendRev'
    saves the deck object as a hash with the deck object's id attribute as the value for the id key in the deck hash
    saves the deck object as a hash with the deck object's last_modified_timestamp attribute as the value for the mod key in the deck hash

```

The RSpec test suite files in `spec` are organized similarly to the the source code in `lib`.

<!-- ## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Development road map:
- Better messages when `ArgumentError` raised
- Add #inspect methods
- Refactor tests to improve speed
- Copying the contents of an existing package into the new package when it is opened
    - Add more unit tests
- Work on creating, updating, and saving notes and cards to the collection.anki21 database
    - Updating notes when they already exist in the database
        - Add more unit tests
    - Validation logic of what makes the note valid based on the note type's card templates and fields
    - Work on adding media support
      - The checksum calculation for notes will need to be updated to account for HTML in the content
- Saving note types, decks, and deck options groups to the collection.anki21 database
    - Deck options groups cannot be saved yet.
    - Add being able to handle subdecks
    - Updating them when they already exist
    - Setters for any relevant attributes with validation
- Refactoring
    - Use more specific RSpec matchers than `eq` everywhere
    - Investigate if note guid is determined in Anki in a non-random way
    - Investigate if the database ever needs to be explicitly opened or closed
- Note type allowed fields: investigate if there are other special field names that should be allowed.

### Release checklist
- Remove `require "pry"`
- Update changelog
- Update usage examples
- Update and regenerate documentation
- Bump version
- Release gem -->

<!-- ## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/KyleRego/anki_record. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/KyleRego/anki_record/blob/master/CODE_OF_CONDUCT.md). -->

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Anki Record project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/KyleRego/anki_record/blob/main/CODE_OF_CONDUCT.md).
