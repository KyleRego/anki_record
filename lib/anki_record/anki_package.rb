# frozen_string_literal: true

require "pry"
require "pathname"

require_relative "card"
require_relative "note"

require_relative "db/anki_schema_definition"
require_relative "db/clean_collection2_record"
require_relative "db/clean_collection21_record"
require_relative "collection"

module AnkiRecord
  ##
  # Represents an Anki package
  class AnkiPackage
    ##
    # The collection object of the package
    attr_reader :collection

    ##
    # Creates a new object which represents an Anki package. See README for details.
    def initialize(name:, directory: Dir.pwd, &closure)
      check_name_argument_is_valid(name:)
      @name = name.end_with?(".apkg") ? name[0, name.length - 5] : name
      @directory = directory
      check_directory_argument_is_valid
      setup_other_package_instance_variables(name: name, directory: directory)

      execute_closure_and_zip(self, &closure) if block_given?
    end

    def execute(raw_sql_string) # :nodoc:
      @anki21_database.execute raw_sql_string
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

      def setup_other_package_instance_variables(name:, directory:)
        @tmpdir = Dir.mktmpdir
        @tmp_files = []
        @anki21_database = setup_anki21_database_object
        @anki2_database = setup_anki2_database_object
        @media_file = setup_media
        @collection = Collection.new(anki_package: self)
      end

      def check_name_argument_is_valid(name:)
        unless name.instance_of?(String) && !name.empty? && !name.include?(" ")
          raise ArgumentError, "The name argument must be a string without spaces."
        end
      end

      def check_directory_argument_is_valid
        raise ArgumentError, "No directory was found at the given path." unless File.directory?(@directory)
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

      def standard_error_thrown_in_block_message
        <<-MSG
        An error occurred.
        The temporary files (databases and media) have been deleted.
        No new *.apkg zip file has been saved.
        MSG
      end

      def puts_error_and_standard_message(error:)
        puts "#{error}\n#{standard_error_thrown_in_block_message}"
      end

    public

    ##
    # Creates a new object which represents a copy of an already existing Anki package. See README for details.
    def self.open(path:, target_directory: nil, &closure)
      pathname = Pathname.new(path)
      check_file_is_valid_at pathname: pathname
      new_apkg_name = "#{File.basename(pathname.to_s, ".apkg")}-#{seconds_since_epoch}"

      @anki_package = if target_directory
                        new(name: new_apkg_name, directory: target_directory)
                      else
                        new(name: new_apkg_name)
                      end
      @anki_package.send :execute_closure_and_zip, @anki_package, &closure if block_given?
      @anki_package
    end

    class << self
      include TimeHelper

      private

        def check_file_is_valid_at(pathname:)
          raise "*No .apkg file was found at the given path." unless pathname.file? && pathname.extname == ".apkg"
        end
    end

    ##
    # Zips the temporary files into the *.apkg package and deletes the temporary files.
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
        "#{@directory}/#{@name}.apkg"
      end

      def destroy_temporary_directory
        @anki21_database.close
        FileUtils.rm_rf(@tmpdir)
      end

    public

    ##
    # Returns true if the database is open
    def open?
      !closed?
    end

    ##
    # Returns true if the database is closed
    def closed?
      @anki21_database.closed?
    end
  end
end
