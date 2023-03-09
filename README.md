# Anki Record

Anki Record is a Ruby library which provides a programmatic interface to Anki flashcard decks (`*.apkg` files, or Anki SQLite databases). **It is in an early stage of development and the API is not stable. I do not recommend you try it yet.**

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add anki_record

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install anki_record

## Documentation

The [API Documentation](https://kylerego.github.io/anki_record_docs) is generated using RDoc from comments in the source code. You might notice that some public methods are intentionally omitted from this documentation. Although public, these methods are not intended to be used outside of the gem's implementation and should be treated as private.

The RSpec examples are intended to provide executable documentation and reading them may be helpful to understand the API. The best way is to run the test suite with the `rspec` command. The output is formatted as colorful documentation with a nesting pattern that reflects the nesting of the RSpec examples and example groups.

There is a corresponding RSpec file for every file in the library code. The following organizes these in roughly the way the objects collaborate:
- [anki_package_spec.rb](https://github.com/KyleRego/anki_record/blob/main/spec/anki_record/anki_package_spec.rb)
  - [collection_spec.rb](https://github.com/KyleRego/anki_record/blob/main/spec/anki_record/collection_spec.rb)
    - [note_type_spec.rb](https://github.com/KyleRego/anki_record/blob/main/spec/anki_record/note_type_spec.rb)
      - [note_field_spec.rb](https://github.com/KyleRego/anki_record/blob/main/spec/anki_record/note_field_spec.rb)
      - [card_template_spec.rb](https://github.com/KyleRego/anki_record/blob/main/spec/anki_record/card_template_spec.rb)
    - [deck_spec.rb](https://github.com/KyleRego/anki_record/blob/main/spec/anki_record/deck_spec.rb)
    - [deck_options_group_spec.rb](https://github.com/KyleRego/anki_record/blob/main/spec/anki_record/deck_options_group_spec.rb)
  - [note_spec.rb](https://github.com/KyleRego/anki_record/blob/main/spec/anki_record/note_spec.rb)
    - [card_spec.rb](https://github.com/KyleRego/anki_record/blob/main/spec/anki_record/card_spec.rb)

The section below should provide examples of the most common things you might want to do.

## Usage

The Anki package object is instantiated with `AnkiRecord::AnkiPackage.new` and if passed a block, will execute the block, and then zip the `*.apkg` file:

```ruby
require "anki_record"

AnkiRecord::AnkiPackage.new(name: "test") do |apkg|
  3.times do |number|
    puts "#{3 - number}..."
  end
  puts "Countdown complete. Write any Ruby you want in here!"
end
```

If an exception is raised inside the block, the temporary `collection.anki2` and `collection.anki21` databases and `media` file are deleted without creating a new `*.apkg` zip file, so this is the recommended way.

Alternatively, if `AnkiRecord::Package::new` is not passed a block, the `zip` method must be explicitly called on the Anki package object:

```ruby
require "anki_record"

apkg = AnkiRecord::AnkiPackage.new(name: "test")
apkg.zip
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Development road map:
- Saving note types, decks, and deck options groups to the collection.anki21 database
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
