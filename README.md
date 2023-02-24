# AnkiRecord

AnkiRecord provides an interface to Anki SQLite databases through the Ruby programming language.

Currently it can be used to create an empty Anki database file, execute raw SQL statements against it, and then zip the database into an *.apkg file which can be imported into Anki.

[Documentation](https://kylerego.github.io/anki_record_docs)

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add anki_record

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install anki_record

## Usage

```ruby
require "anki_record"

db = AnkiRecord::AnkiPackage.new name: "test1"
db.execute "any valid SQL statement"
db.zip_and_close # creates test.apkg file in the current working directory

```

The RSpec tests are written BDD-style as executable documentation; reading them might help to understand the gem (e.g. [anki_package_spec.rb](https://github.com/KyleRego/anki_record/blob/main/spec/anki_record/anki_package_spec.rb)).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Release checklist
- Bump version
- Update changelog
- Regenerate documentation

<!-- ## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/KyleRego/anki_record. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/KyleRego/anki_record/blob/master/CODE_OF_CONDUCT.md). -->

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AnkiRecord project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/KyleRegoanki_record/blob/main/CODE_OF_CONDUCT.md).
