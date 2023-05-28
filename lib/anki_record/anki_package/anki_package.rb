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
    attr_reader :collection, :anki21_database, :anki2_database, :media, :tmpdir, :tmpfiles, :target_directory, :name

    ##
    # Creates a new Anki package file (see README).
    def initialize(name:, target_directory: Dir.pwd, &closure)
      validate_arguments(name: name, target_directory: target_directory)
      @name = new_apkg_name(name: name)
      @target_directory = target_directory
      @tmpdir = Dir.mktmpdir
      @tmpfiles = [Anki21Database::FILENAME, Anki2Database::FILENAME, Media::FILENAME]
      @anki21_database = Anki21Database.new(tmpdir: tmpdir)
      @anki2_database = Anki2Database.new(tmpdir: tmpdir)
      @media = Media.new(tmpdir: tmpdir)
      @collection = Collection.new(anki21_database: anki21_database)

      execute_closure_and_zip(collection, &closure) if closure
    end

    ##
    # Zips the Anki package into an apkg file. The temporary directory/files are also deleted.
    def zip
      create_zip_file && destroy_temporary_directory
    end

    private

      def validate_arguments(name:, target_directory:)
        check_name_argument_is_valid(name: name)
        check_target_directory_argument_is_valid(target_directory: target_directory)
      end

      def new_apkg_name(name:)
        name.end_with?(".apkg") ? name[0, name.length - 5] : name
      end

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

      def check_target_directory_argument_is_valid(target_directory:)
        return if File.directory?(target_directory)

        raise ArgumentError, "No directory was found at the given path."
      end

      def output_error(error:)
        puts error.backtrace.reverse
        puts error
        puts "Anki Record: An error occurred."
        puts "Any temporary files created have been deleted."
        puts "No new *.apkg zip file was saved."
      end

      def create_zip_file
        Zip::File.open(target_zip_file, create: true) do |zip_file|
          tmpfiles.each do |file_name|
            zip_file.add(file_name, File.join(tmpdir, file_name))
          end
        end
        true
      end

      def target_zip_file
        "#{target_directory}/#{name}.apkg"
      end

      def destroy_temporary_directory
        FileUtils.rm_rf(tmpdir)
      end
  end
end
