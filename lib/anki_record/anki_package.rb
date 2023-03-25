# frozen_string_literal: true

require "pathname"

require_relative "card"
require_relative "collection/collection"
require_relative "note"

require_relative "db/anki_schema_definition"
require_relative "db/clean_collection2_record"
require_relative "db/clean_collection21_record"

# rubocop:disable Metrics/ClassLength
module AnkiRecord
  ##
  # AnkiPackage represents an Anki package.
  #
  # Here, Anki package refers to the zip file that Anki can export and import.
  class AnkiPackage
    include AnkiRecord::DataQueryHelper

    ##
    # The package's collection object.
    attr_reader :collection

    ##
    # Instantiates a new Anki package object.
    #
    # See the README for usage details.
    def initialize(name:, target_directory: Dir.pwd, data: nil, open_path: nil, &closure)
      check_name_argument_is_valid(name:)
      @name = name.end_with?(".apkg") ? name[0, name.length - 5] : name
      @target_directory = target_directory
      @open_path = open_path
      check_directory_argument_is_valid
      setup_other_package_instance_variables
      insert_existing_data(data: data) if data

      execute_closure_and_zip(collection, &closure) if block_given?
    end

    # Returns an SQLite3::Statement object representing the given SQL and coupled to the collection.anki21 database.
    #
    # The Statement is executed using Statement#execute (refer to the sqlite3 gem documentation).
    def prepare(sql)
      @anki21_database.prepare sql
    end

    private

      def execute_closure_and_zip(object_to_yield, &closure)
        closure.call(object_to_yield)
      rescue StandardError => e
        destroy_temporary_directory
        puts_error_and_standard_message(error: e)
      else
        zip
      end

      def setup_other_package_instance_variables
        @tmpdir = Dir.mktmpdir
        @tmp_files = []
        @anki21_database = setup_anki21_database_object
        @anki2_database = setup_anki2_database_object
        @media_file = setup_media
        @collection = Collection.new(anki_package: self)
      end

      def check_name_argument_is_valid(name:)
        return if name.instance_of?(String) && !name.empty? && !name.include?(" ")

        raise ArgumentError, "The name argument must be a string without spaces."
      end

      def check_directory_argument_is_valid
        raise ArgumentError, "No directory was found at the given path." unless File.directory?(@target_directory)
      end

      def setup_anki21_database_object
        anki21_file_name = "collection.anki21"
        db = SQLite3::Database.new "#{@tmpdir}/#{anki21_file_name}", options: {}
        @tmp_files << anki21_file_name
        db.execute_batch ANKI_SCHEMA_DEFINITION
        db.execute CLEAN_COLLECTION_21_RECORD
        db.results_as_hash = true
        db
      end

      def setup_anki2_database_object
        anki2_file_name = "collection.anki2"
        db = SQLite3::Database.new "#{@tmpdir}/#{anki2_file_name}", options: {}
        @tmp_files << anki2_file_name
        db.execute_batch ANKI_SCHEMA_DEFINITION
        db.execute CLEAN_COLLECTION_2_RECORD
        db.close
        db
      end

      def setup_media
        media_file_path = FileUtils.touch("#{@tmpdir}/media")[0]
        media_file = File.open(media_file_path, mode: "w")
        media_file.write("{}")
        media_file.close
        @tmp_files << "media"
        media_file
      end

      def insert_existing_data(data:)
        @collection.copy_over_existing(col_record: data[:col_record])
        copy_over_notes_and_cards(note_ids: data[:note_ids])
      end

      def copy_over_notes_and_cards(note_ids:)
        temporarily_unzip_source_apkg do |source_collection_anki21|
          note_ids.each do |note_id|
            note_cards_data = note_cards_data_for_note_id(sql_able: source_collection_anki21, id: note_id)
            AnkiRecord::Note.new(collection: @collection, data: note_cards_data).save
          end
        end
      end

      def standard_error_thrown_in_block_message
        "Any temporary files created have been deleted.\nNo new *.apkg zip file was saved."
      end

      def puts_error_and_standard_message(error:)
        puts error.backtrace
        puts "#{error}\n#{standard_error_thrown_in_block_message}"
      end

    public

    ##
    # Instantiates a new Anki package object which seeded with data from an already existing Anki package.
    #
    # See the README for details.
    def self.open(path:, target_directory: nil, &closure)
      pathname = Pathname.new(path)
      raise "*No .apkg file was found at the given path." unless pathname.file? && pathname.extname == ".apkg"

      new_apkg_name = "#{File.basename(pathname.to_s, ".apkg")}-#{seconds_since_epoch}"
      data = col_record_and_note_ids_to_copy_over(pathname: pathname)

      if target_directory
        new(name: new_apkg_name, data: data, open_path: pathname,
            target_directory: target_directory, &closure)
      else
        new(name: new_apkg_name, data: data, open_path: pathname, &closure)
      end
    end

    ##
    # Returns true if the Anki package object was instantiated using ::open.
    def was_instantiated_from_existing_apkg?
      !@open_path.nil?
    end

    # rubocop:disable Metrics/MethodLength

    ##
    # Unzips the *.apkg file that was opened and yields its collection.anki21 database
    # as a SQLite3::Database object to the block argument.
    #
    # After the block executes, the files created by unzipping are deleted.
    #
    # Throws an error if the Anki package was not instantiated using ::open.
    #
    def temporarily_unzip_source_apkg
      raise ArgumentError unless @open_path && block_given?

      Zip::File.open(@open_path) do |zip_file|
        zip_file.each do |entry|
          next unless entry.name == "collection.anki21"

          entry.extract
          source_collection_anki21 = SQLite3::Database.open "collection.anki21"
          source_collection_anki21.results_as_hash = true

          yield source_collection_anki21
        end
      end
      File.delete("collection.anki21")
    end
    # rubocop:enable Metrics/MethodLength

    class << self
      include TimeHelper

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def col_record_and_note_ids_to_copy_over(pathname:) # :nodoc:
        data = {}
        Zip::File.open(pathname) do |zip_file|
          zip_file.each do |entry|
            next unless entry.name == "collection.anki21"

            entry.extract
            source_collection_anki21 = SQLite3::Database.open "collection.anki21"
            source_collection_anki21.results_as_hash = true
            col_record = source_collection_anki21.prepare("select * from col").execute.first
            note_ids = source_collection_anki21.prepare("select id from notes").execute.map { |note| note["id"] }
            data = { col_record: col_record, note_ids: note_ids }
          end
        end
        File.delete("collection.anki21")
        data
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end

    ##
    # Zips the temporary files (collection.anki21, collection.anki2, and media) into a new *.apkg package file.
    #
    # The temporary files, and the temporary directory they were in, are deleted after zipping.
    def zip
      create_zip_file && destroy_temporary_directory
    end

    private

      def create_zip_file
        Zip::File.open(target_zip_file, create: true) do |zip_file|
          @tmp_files.each do |file_name|
            zip_file.add(file_name, File.join(@tmpdir, file_name))
          end
        end
        true
      end

      def target_zip_file
        "#{@target_directory}/#{@name}.apkg"
      end

      def destroy_temporary_directory
        FileUtils.rm_rf(@tmpdir)
      end

    public

    def open? # :nodoc:
      !closed?
    end

    def closed? # :nodoc:
      @anki21_database.closed?
    end
  end
end
# rubocop:enable Metrics/ClassLength
