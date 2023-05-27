# frozen_string_literal: true

module AnkiRecord
  ##
  # AnkiDatabase represents the collection.anki21 Anki SQLite database
  class Anki2Database
    attr_reader :database

    FILENAME = "collection.anki2"

    def initialize(tmpdir:)
      @database = SQLite3::Database.new "#{tmpdir}/#{FILENAME}", options: {}
      database.execute_batch ANKI_SCHEMA_DEFINITION
      database.execute INSERT_COLLECTION_ANKI_2_COL_RECORD
      database.close
    end
  end
end
