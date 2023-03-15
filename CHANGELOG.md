## [Development started] - 02-02-2023

## [0.1.1] - 02-24-2023

- Initial release
- Supports creating an `*.apkg` file that imports correctly into Anki
- SQL statements can be executed against the `collection.anki21` database of that package

## [0.2.0] - 03-05-2023

- `AnkiPackage#zip_and_close` is changed to `AnkiPackage#zip`
- Decks and note types can be accessed through the collection object
- Notes can be created, updated, and saved to the database, and this also populates corresponding records in the `cards` table