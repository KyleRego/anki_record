## [Development started] - 02-02-2023

## [Unreleased/0.1.0] - 02-22-2023

- The gem can be used to create an *.apkg zip file that successfully imports into Anki.
- Raw SQL statements can be executed against the temporary database before it is zipped.

## [0.1.1] - 02-24-2023

- Updated documentation to release the first version

## [0.2.0] - 03-05-2023

- `AnkiPackage#zip_and_close` is changed to `AnkiPackage#zip`
- Decks and note types can be accessed through the collection object
- Notes can be created, updated, and saved to the database and this also populates the corresponding records in the `cards` table