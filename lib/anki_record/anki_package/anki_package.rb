# frozen_string_literal: true

require "pathname"

require_relative "../anki2_database/anki2_database"
require_relative "../anki21_database/anki21_database"
require_relative "../media/media"
require_relative "../card/card"
require_relative "../collection/collection"
require_relative "../note/note"
require_relative "../database_setup_constants"

module AnkiRecord
  ##
  # AnkiPackage represents an Anki package deck file.
  class AnkiPackage
    include AnkiRecord::Helpers::DataQueryHelper

    attr_reader :collection, :anki21_database, :anki2_database, :media, :tmpdir, :tmpfiles

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    ##
    # Creates a new Anki package file (see README).
    def initialize(name:, target_directory: Dir.pwd, data: nil, open_path: nil, &closure)
      check_name_argument_is_valid(name:)
      @name = name.end_with?(".apkg") ? name[0, name.length - 5] : name
      @target_directory = target_directory
      @open_path = open_path
      check_directory_argument_is_valid
      @tmpdir = Dir.mktmpdir
      @tmpfiles = [Anki21Database::FILENAME, Anki2Database::FILENAME, Media::FILENAME]
      @anki21_database = Anki21Database.new(tmpdir: tmpdir)
      @anki2_database = Anki2Database.new(tmpdir: tmpdir)
      @media = Media.new(tmpdir: tmpdir)
      @collection = Collection.new(anki21_database: anki21_database)
      insert_existing_data(data: data) if data

      execute_closure_and_zip(collection, &closure) if closure
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    ##
    # Opens an existing Anki package file (see README).
    def self.open(path:, &closure)
      pathname = Pathname.new(path)
      raise "*No .apkg file was found at the given path." unless pathname.file? && pathname.extname == ".apkg"

      new_apkg_name = "#{File.basename(pathname.to_s, ".apkg")}-#{seconds_since_epoch}"
      data = col_record_and_note_ids_to_copy_over(pathname: pathname)

      new(name: new_apkg_name, data: data, open_path: pathname, &closure)
    end

    private

      def execute_closure_and_zip(collection)
        yield(collection)
      rescue StandardError => e
        destroy_temporary_directory
        output_error(error: e)
      else
        zip
      end

      def check_name_argument_is_valid(name:)
        return if name.instance_of?(String) && !name.empty? && !name.include?(" ")

        raise ArgumentError, "The package name must be a string without spaces."
      end

      def check_directory_argument_is_valid
        raise ArgumentError, "No directory was found at the given path." unless File.directory?(@target_directory)
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

      def output_error(error:)
        puts error.backtrace
        puts "#{error}\n#{standard_error_thrown_in_block_message}"
      end

    public

    def was_instantiated_from_existing_apkg? # :nodoc:
      !@open_path.nil?
    end

    # rubocop:disable Metrics/MethodLength
    # :nodoc:
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
      include Helpers::TimeHelper

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
          tmpfiles.each do |file_name|
            zip_file.add(file_name, File.join(tmpdir, file_name))
          end
        end
        true
      end

      def target_zip_file
        "#{@target_directory}/#{@name}.apkg"
      end

      def destroy_temporary_directory
        FileUtils.rm_rf(tmpdir)
      end

    public

    # :nodoc:
    def open?
      !closed?
    end

    # :nodoc:
    def closed?
      anki21_database.closed?
    end
  end
end
