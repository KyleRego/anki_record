# frozen_string_literal: true

module AnkiRecord
  ##
  # AnkiDatabase represents a collection.anki21 Anki SQLite database.
  class Anki21Database
    attr_reader :anki_package, :collection, :database

    FILENAME = "collection.anki21"

    def initialize(anki_package:)
      @anki_package = anki_package
      @database = SQLite3::Database.new "#{anki_package.tmpdir}/#{FILENAME}", options: {}
      database.execute_batch ANKI_SCHEMA_DEFINITION
      database.execute INSERT_COLLECTION_ANKI_21_COL_RECORD
      database.results_as_hash = true
      @collection = Collection.new(anki21_database: self)
      database
    end

    # Returns an SQLite3::Statement object to be executed against the collection.anki21 database.
    #
    # Statement#execute executes the statement.
    def prepare(sql)
      database.prepare sql
    end

    ##
    # Returns the note found by +id+, or nil if it is not found.
    def find_note_by(id:)
      note_cards_data = note_cards_data_for_note_id(id: id)
      return nil unless note_cards_data

      AnkiRecord::Note.new(anki21_database: self, data: note_cards_data)
    end

    private

      def note_cards_data_for_note_id(id:)
        note_data = prepare("select * from notes where id = ?").execute([id]).first
        return nil unless note_data

        cards_data = prepare("select * from cards where nid = ?").execute([id]).to_a
        { note_data: note_data, cards_data: cards_data }
      end
  end
end
