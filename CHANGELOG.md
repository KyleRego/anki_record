## [Development started] - 02-02-2023

## [0.1.1] - 02-24-2023

- The initial version released.
- The gem can create empty `.apkg` files that import into Anki.
- SQL statements can be executed against the `collection.anki21` database before the zip file is created.

## [0.2.0] - 03-05-2023

- `AnkiPackage#zip_and_close` renamed to `AnkiPackage#zip`.
- Decks and note types can be accessed with `Collection#find_deck_by` and `Collection#find_note_type_by`.
- Note objects can be created and updated, and then saved to the `collection.anki21` database.
  - This also populates corresponding records in the `cards` table.

## [0.3.0] - 03-26-2023

- `AnkiPackage::new` yields the collection object to the block instead of the Anki package object.
- `AnkiPackage::open` has been developed to a point that it is useable.
  - An "opened" Anki package now has its contents copied into the temporary `collection.anki21` database.
- `AnkiPackage#execute` was removed.
  - `AnkiPackage#prepare` was added. Any SQL statements executed directly against `collection.anki21` must now be prepared statements.
- Custom decks (and nested decks/subdecks) and custom note types can be created and updated, and then saved to the `collection.anki21` database.
- Notes can be accessed with `Collection#find_note_by`.
- `Note#save` now updates a note (and its corresponding cards) if it was already in the `collection.anki21` database.
- `Note::new` does not accept a `cloze` argument anymore; this attribute can be changed after instantiation with the `cloze=` setter.
- `Deck` has a `deck_options_group` attribute instead of `deck_options_group_id`
- `#inspect` added to `Deck`
- Deck options groups can be accessed with `Collection#find_deck_options_group_by`
- Multiple classes with `last_modified_time` and `creation_timestamp` attributes had these renamed to `last_modified_timestamp` and `created_at_timestamp`.
- More helpful error messages in various places (e.g. "The package name must be a string without spaces.").
- Bug fixes that may have affected previous version:
  - Instantiating a note type from an existing Anki package no longer duplicates the note type when it is saved.
  - Note types are not instantiated/saved with an invalid `req` value.
    - In fixing this bug, other issues with `tags` and `vers` were introduced and then fixed.
    - It was also noticed that the default note types with "Basic" in the name should not have `tags` and `vers` so this was changed too.
- API documentation changed from using RDoc to SDoc with the Rails template.
- RSpec test suite was refactored to improve speed: 4 minutes -> 1.5 minutes.

## [0.3.1] - 04-29-2023

- `Deck.new` was saving the deck to the `collection.anki21` database. Now it will only instantiate it and `#save` must be called to save it.
- `Helper` modules moved into the `Helpers` module namespace.
- Bug fix addressing using the approximate milliseconds since the epoch as the primary key id causing the uniqueness constraint to fail when creating a lot of notes.

## [0.3.2] - 05-20-2023
- The private `Note` method `globally_unique_id` has been moved to `NoteGuidHelper` and included into note.
- The `guid` attribute also now has a public setter.

## [0.4] - 07-08-2023
- `AnkiPackage.new` and `AnkiPackage.open` have been removed and replaced with `AnkiPackage.create` and `AnkiPackage.update`.
- `AnkiPackage.update` is different from `AnkiPackage.open` in that it does not create a new Anki package with a timestamp. It effectively updates the original Anki package file as long as no error is thrown. 
- `Anki21Database` is yielded to the block of the above methods instead of `Collection`.
- Responsibilites of `Collection` have been reorganized to `Anki21Database`.
- The `guid` attribute of notes ic computed in a different way that allows a larger number of possible values.
- `globally_unique_id` is now a module method rather than an included instance method.

## [0.4.1] - 08-21-2023
- `Anki21Database#find_note_by` now can take the sort field value of a note as argument.
- `Anki21Database#find_notes_by_exact_text_match` is a new method that returns an array of notes that have in any field text matching the argument.
- Trying to create an Anki package file with a path/name that already exists raises a more helpful error message.
- Saving a note to the database saves the `mod` column (last modified time) to make it easier to import an updated package into Anki.
