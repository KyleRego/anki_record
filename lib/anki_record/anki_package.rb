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
  # Represents an Anki SQLite3 package/database
  #
  # Use ::new to create a new object or ::open to create an object from an existing one
  class AnkiPackage
    NAME_ERROR_MESSAGE = "The name argument must be a string without spaces."
    PATH_ERROR_MESSAGE = "*No .apkg file was found at the given path."
    STANDARD_ERROR_MESSAGE = <<-MSG
    An error occurred.
    The temporary *.anki21 database has been deleted.
    No *.apkg zip file has been saved.
    MSG

    private_constant :NAME_ERROR_MESSAGE, :PATH_ERROR_MESSAGE, :STANDARD_ERROR_MESSAGE

    ##
    # The collection object of the package
    attr_reader :collection

    ##
    # Creates a new object which represents an Anki SQLite3 database
    #
    # This method takes an optional block argument.
    #
    # When a block argument is used, execution is yielded to the block.
    # After the block executes, the temporary files are zipped into the +name+.apkg file
    # which is saved in +directory+. +directory+ is the current working directory by default.
    # If the block throws a runtime error, the temporary files are deleted but the zip file is not created.
    #
    # When no block argument is used, #zip must be called explicitly at the end of your script.
    def initialize(name:, directory: Dir.pwd, &closure)
      setup_package_instance_variables(name: name, directory: directory)

      execute_closure_and_zip(self, &closure) if block_given?
    end

    ##
    # Executes a raw SQL statement against the *.anki21 database
    #
    # Do not use this to execute data definition language SQL statements
    # (i.e. do not create, alter, or drop tables or indexes)
    # unless you have a good reason to change the database schema.
    def execute(raw_sql_string)
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

      def setup_package_instance_variables(name:, directory:)
        @name = check_name_is_valid(name: name)
        @directory = directory # TODO: check directory is valid
        @tmpdir = Dir.mktmpdir
        @tmp_files = []
        @anki21_database = setup_anki21_database_object
        @anki2_database = setup_anki2_database_object
        @media_file = setup_media
        @collection = Collection.new(anki_package: self)
      end

      def check_name_is_valid(name:)
        raise ArgumentError, NAME_ERROR_MESSAGE unless name.instance_of?(String) && !name.empty? && !name.include?(" ")

        name.end_with?(".apkg") ? name[0, name.length - 5] : name
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

      def puts_error_and_standard_message(error:)
        puts "#{error}\n#{STANDARD_ERROR_MESSAGE}"
      end

    public

    ##
    # Creates a new object which represents the Anki SQLite3 database file at +path+
    #
    # Development has focused on ::new so this method is not recommended at this time
    def self.open(path:, target_directory: nil, &closure)
      pathname = check_file_at_path_is_valid(path: path)
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

        def check_file_at_path_is_valid(path:)
          pathname = Pathname.new(path)
          raise PATH_ERROR_MESSAGE unless pathname.file? && pathname.extname == ".apkg"

          pathname
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
