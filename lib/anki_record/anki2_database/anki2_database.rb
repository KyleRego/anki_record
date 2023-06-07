# frozen_string_literal: true

module AnkiRecord
  ##
  # AnkiDatabase represents the collection.anki21 Anki SQLite database
  class Anki2Database
    attr_reader :anki_package, :database

    FILENAME = "collection.anki2"

    def initialize(anki_package:)
      @anki_package = anki_package
      @database = SQLite3::Database.new "#{anki_package.tmpdir}/#{FILENAME}", options: {}
      database.execute_batch ANKI_SCHEMA_DEFINITION
      database.execute INSERT_COLLECTION_ANKI_2_COL_RECORD
      database.close
      database
    end
  end
end
