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
  # AnkiPackage represents the Anki deck package file which has the .apkg file extension
  #
  # This is a zip file containing two SQLite databases (collection.anki21 and collection.anki2),
  # a media file, and possibly the media (images and sound files). The gem currently does not
  # have any support for adding or changing media in the Anki package.
  class AnkiPackage
    attr_accessor :anki21_database, :anki2_database, :media, :tmpdir, :tmpfiles, :target_directory, :name # :nodoc:

    ##
    # Creates a new Anki package file (see the README)
    def self.create(name:, target_directory: Dir.pwd, &closure)
      anki_package = new
      anki_package.create_initialize(name:, target_directory:, &closure)
      anki_package
    end

    def create_initialize(name:, target_directory: Dir.pwd, &closure) # :nodoc:
      validate_arguments(name:, target_directory:)
      @name = new_apkg_name(name:)
      @target_directory = target_directory
      @tmpdir = Dir.mktmpdir
      @tmpfiles = [Anki21Database::FILENAME, Anki2Database::FILENAME, Media::FILENAME]
      @anki21_database = Anki21Database.create_new(anki_package: self)
      @anki2_database = Anki2Database.create_new(anki_package: self)
      @media = Media.create_new(anki_package: self)

      execute_closure_and_zip(anki21_database, &closure) if closure
    end

    ##
    # Opens an existing Anki package file to update its contents (see the README)
    def self.update(path:, &closure)
      anki_package = new
      anki_package.update_initialize(path:, &closure)
      anki_package
    end

    def update_initialize(path:, &closure) # :nodoc:
      validate_path(path:)

      @tmpdir = Dir.mktmpdir
      unzip_apkg_into_tmpdir(path:)
      @tmpfiles = [Anki21Database::FILENAME, Anki2Database::FILENAME, Media::FILENAME]
      @anki21_database = Anki21Database.update_new(anki_package: self)
      @anki2_database = Anki2Database.update_new(anki_package: self)
      @media = Media.update_new(anki_package: self)

      @updating_existing_apkg = true
      execute_closure_and_zip(anki21_database, &closure) if closure
    end

    # :nodoc:
    def zip
      @updating_existing_apkg ? replace_zip_file : create_zip_file
      destroy_temporary_directory
    end

    # :nocov:
    def inspect
      "[= AnkiPackage name: #{name} target_directory: #{target_directory} =]"
    end
    # :nocov:

    private

      def validate_path(path:)
        pathname = Pathname.new(path)
        raise "*No .apkg file was found at the given path." unless pathname.file? && pathname.extname == ".apkg"

        @name = File.basename(pathname.to_s, ".apkg")
        @target_directory = pathname.expand_path.dirname.to_s
      end

      def unzip_apkg_into_tmpdir(path:)
        Zip::File.open(path) do |zip_file|
          zip_file.each do |entry|
            entry.extract("#{tmpdir}/#{entry.name}")
          end
        end
      end

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

      # rubocop:disable Metrics/MethodLength
      def execute_closure_and_zip(anki21_database)
        yield(anki21_database)
      rescue StandardError => e
        destroy_temporary_directory
        puts e.backtrace.reverse
        puts e
        puts "An error occurred within the block argument."
        puts "The temporary files have been deleted."
        puts "If you were creating a new Anki package, nothing was saved."
        puts "If you were updating an existing one, it was not changed."
      else
        zip
      end
      # rubocop:enable Metrics/MethodLength

      def destroy_temporary_directory
        FileUtils.rm_rf(tmpdir)
      end

      def create_zip_file
        Zip::File.open(target_zip_file, create: true) do |zip_file|
          tmpfiles.each do |file_name|
            zip_file.add(file_name, File.join(tmpdir, file_name))
          end
        end
        true
      end

      # rubocop:disable Metrics/MethodLength
      def replace_zip_file
        File.rename(target_zip_file, tmp_original_zip_file)
        begin
          create_zip_file
          FileUtils.rm(tmp_original_zip_file)
        rescue StandardError => e
          puts e.backtrace.reverse
          puts e
          puts "An error occurred during zipping the new version of the Anki package."
          puts "The original package has not been changed"
          File.rename(tmp_original_zip_file, target_zip_file)
        end
        true
      end
      # rubocop:enable Metrics/MethodLength

      def target_zip_file
        "#{target_directory}/#{name}.apkg"
      end

      def tmp_original_zip_file
        "#{target_zip_file}-old"
      end
  end
end
