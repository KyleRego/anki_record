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
  # AnkiPackage represents an Anki deck package file which has the .apkg extension.
  class AnkiPackage
    attr_accessor :anki21_database, :anki2_database, :media, :tmpdir, :tmpfiles, :target_directory, :name

    ##
    # Creates a new Anki package file (see README).
    def self.create(name:, target_directory: Dir.pwd, &closure)
      anki_package = new
      anki_package.create_initialize(name:, target_directory:, &closure)
      anki_package
    end

    def create_initialize(name:, target_directory: Dir.pwd, &closure)
      validate_arguments(name:, target_directory:)
      @name = new_apkg_name(name:)
      @target_directory = target_directory
      @tmpdir = Dir.mktmpdir
      @tmpfiles = [Anki21Database::FILENAME, Anki2Database::FILENAME, Media::FILENAME]
      @anki21_database = Anki21Database.new(anki_package: self)
      @anki2_database = Anki2Database.new(anki_package: self)
      @media = Media.new(anki_package: self)

      execute_closure_and_zip(anki21_database, &closure) if closure
    end

    # :nodoc:
    def zip
      create_zip_file && destroy_temporary_directory
    end

    # :nocov:
    def inspect
      "[= AnkiPackage name: #{name} target_directory: #{target_directory} =]"
    end
    # :nocov:

    protected

      def validate_arguments(name:, target_directory:)
        check_name_argument_is_valid(name:)
        check_target_directory_argument_is_valid(target_directory:)
      end

      def check_name_argument_is_valid(name:)
        return if name.instance_of?(String) && !name.empty? && !name.include?(" ")

        raise ArgumentError, "The package name must be a string without spaces."
      end

      def check_target_directory_argument_is_valid(target_directory:)
        return if File.directory?(target_directory)

        raise ArgumentError, "No directory was found at the given path."
      end

      def new_apkg_name(name:)
        name.end_with?(".apkg") ? name[0, name.length - 5] : name
      end

      def execute_closure_and_zip(anki21_database)
        yield(anki21_database)
      rescue StandardError => e
        destroy_temporary_directory
        output_error_occurred(error: e)
      else
        zip
      end

      def destroy_temporary_directory
        FileUtils.rm_rf(tmpdir)
      end

      def output_error_occurred(error:)
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
  end
end
