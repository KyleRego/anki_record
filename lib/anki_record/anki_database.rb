# frozen_string_literal: true

require "pry"

require_relative "anki_schema_definition"

module AnkiRecord
  # This class represents the Anki database we are creating or updating.
  class AnkiDatabase
    # Constructs a new Anki SQLite3 database file `name.apkg`
    def initialize(name:)
      setup_anki_database_object(name)

      return unless block_given?

      begin
        yield self
      ensure
        zip
        close
      end
    end

    # Opens the Anki SQLite3 database file at `path`
    def open(path)
      # check that the file can be found
      # if it can't -> throw an error

      # unzip the file and assign instance variables
    end

    def open?; end

    def closed?; end

    # Closes the Anki SQLite3 database file and optionally deletes the temporary files
    def close(destroy_temporary_files: true)
      destroy_tmp_files if destroy_temporary_files
      @database.close
    end

    # Zips the Anki SQLite3 database to prepare it for import into Anki
    def zip(directory = Dir.pwd)
      Zip::File.open(target_zip_file_name, create: true) do |zip_file|
        @tmp_files.each do |file_name|
          zip_file.add(file_name, File.join(directory, file_name))
        end
      end
    end

    private

    def setup_anki_database_object(name)
      @name = name
      check_name_is_valid

      @tmp_files = []
      @database = initialize_collection_anki21
      # initialize_collection_anki2
      # initialize_media
    end

    def check_name_is_valid
      raise NameError unless @name
      raise NameError if @name.include?(" ")
    end

    def initialize_collection_anki21
      random_file_name = "#{SecureRandom.hex(10)}.anki21"
      db = SQLite3::Database.new random_file_name, options: {}
      @tmp_files << random_file_name
      db.execute_batch ANKI_SCHEMA_DEFINITION
      db
    end

    def initialize_collection_anki2
      raise NotImplementedError
    end

    def initialize_media
      raise NotImplementedError
    end

    def target_zip_file_name
      "#{@name}.apkg"
    end

    def destroy_tmp_files
      @tmp_files.each { |file_name| File.delete(file_name) }
    end
  end
end
