# frozen_string_literal: true

module AnkiRecord
  ##
  # AnkiDatabase represents the collection.anki21 Anki SQLite database
  class Anki21Database
    attr_reader :database

    FILENAME = "collection.anki21"

    def initialize(tmpdir:)
      @database = SQLite3::Database.new "#{tmpdir}/#{FILENAME}", options: {}
      database.execute_batch ANKI_SCHEMA_DEFINITION
      database.execute INSERT_COLLECTION_ANKI_21_COL_RECORD
      database.results_as_hash = true
      database
    end

    # Returns an SQLite3::Statement object to be executed against the collection.anki21 database.
    #
    # Statement#execute executes the statement.
    def prepare(sql)
      database.prepare sql
    end

    # :nodoc:
    def open?
      !closed?
    end

    # :nodoc:
    def closed?
      database.closed?
    end
  end
end
