## [Development started] - 02-02-2023

## [0.1.1] - 02-24-2023

- An `*.apkg` zip file that imports correctly into Anki can be created.
- SQL statements can be executed against the `collection.anki21` database before zipping.

## [0.2.0] - 03-05-2023

- `AnkiPackage#zip_and_close` has changed to `AnkiPackage#zip`.
- Decks and note types can be accessed through the collection object using `Collection#find_deck_by` and `Collection#find_note_type_by`.
- Notes can be created, updated, and saved to the database, and this also populates corresponding records in the `cards` table.

## [0.3.0] - Unreleased

- `AnkiPackage::new` has changed to yield the collection object to the block instead of the package object.
- `AnkiPackage#execute` has been removed and all SQL statements are executed as prepared statements instantiated with `AnkiPackage#prepare`.
- `Note#save` has changed to now update a note (and its corresponding cards) if it was already existing in the collection.anki21 database.
- `AnkiPackage#open` has been fleshed out such that it is now usable.
  - An opened Anki package now has its contents copied into the new collection.anki21 database.
- `Deck` has been changed to have a `deck_options_group` attribute instead of a `deck_options_group_id`
- Deck options groups can be accessed through the collection object using `Collection#find_deck_options_group_by`
- Fix 2 bugs that may have been in previous versions but were not part of the recommended API:
  - Instantiating a note type from an existing Anki package no longer duplicates the note type when it is saved
  - Note types are not instantiated/saved with an invalid req value
- `#inspect` added to `Deck`