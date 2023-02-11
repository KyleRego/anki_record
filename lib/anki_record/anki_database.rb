# frozen_string_literal: true

require "pry"

require_relative "anki_schema_definition"

module AnkiRecord
  # Represents the Anki database we are creating or interacting with.
  class AnkiDatabase
    # The constructor method
    # When passed a block:
    # - Yields execution to the block
    # - When the block is done, zips the database files and closes the database
    # When not passed a block:
    # - #zip and #close must be used explicitly
    def initialize(name:, directory: Dir.pwd)
      setup_instance_variables(name: name, directory: directory)

      return unless block_given?

      begin
        yield self
      rescue StandardError => e
        puts e
      ensure
        zip_and_close
      end
    end

    private

      def setup_instance_variables(name:, directory:)
        @name = check_name_is_valid(name: name)
        @directory = directory
        @tmp_files = []
        @anki21_database = setup_anki21_database_object
      end

      def check_name_is_valid(name:)
        raise ArgumentError unless name.instance_of?(String) && !name.empty? && !name.include?(" ")

        name
      end

      def setup_anki21_database_object
        random_file_name = "#{SecureRandom.hex(10)}.anki21"
        db = SQLite3::Database.new "#{@directory}/#{random_file_name}", options: {}
        @tmp_files << random_file_name
        db.execute_batch ANKI_SCHEMA_DEFINITION
        db
      end

    public

    # Zips the Anki database, deletes the temporary *.anki21 file, and closes the database
    def zip_and_close(destroy_temporary_files: true)
      zip && close(destroy_temporary_files: destroy_temporary_files)
    end

    private

      def zip
        Zip::File.open(target_zip_file, create: true) do |zip_file|
          @tmp_files.each do |file_name|
            zip_file.add(file_name, File.join(@directory, file_name))
          end
        end
        true
      end

      def target_zip_file
        "#{@directory}/#{@name}.apkg"
      end

      def close(destroy_temporary_files:)
        destroy_tmp_files if destroy_temporary_files
        @anki21_database.close
      end

      def destroy_tmp_files
        @tmp_files.each { |file_name| File.delete("#{@directory}/#{file_name}") }
      end

    public

    # Opens the Anki SQLite3 database file at `path`
    def open(path)
      # check that the file can be found
      # if it can't -> throw an error

      # unzip the file and assign instance variables
    end

    # Returns true if the database is open and false if it is closed
    def open?
      !closed?
    end

    # Returns true if the database is closed and true if it is open
    def closed?
      @anki21_database.closed?
    end
  end
end
