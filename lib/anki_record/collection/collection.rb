# frozen_string_literal: true

require "json"

require_relative "../deck/deck"
require_relative "../deck_options_group/deck_options_group"
require_relative "../helpers/time_helper"
require_relative "../note_type/note_type"
require_relative "collection_attributes"

module AnkiRecord
  ##
  # Collection represents the single record in the Anki collection.anki21 database's `col` table.
  # The note types, decks, and deck options groups data are contained within this record, but
  # for simplicity of the gem's API, they are managed by the Anki21Database class.
  class Collection
    include Helpers::TimeHelper
    include CollectionAttributes

    attr_reader :anki21_database

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # :nodoc:
    def initialize(anki21_database:)
      @anki21_database = anki21_database
      @id = col_record["id"]
      @created_at_timestamp = col_record["crt"]
      @last_modified_timestamp = col_record["mod"]
      @scm = col_record["scm"]
      @ver = col_record["ver"]
      @dty = col_record["dty"]
      @usn = col_record["usn"]
      @ls = col_record["ls"]
      @configuration = JSON.parse(col_record["conf"])
      @tags = JSON.parse(col_record["tags"])
      remove_instance_variable(:@col_record)
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    private

      def col_record
        @col_record ||= anki21_database.col_record
      end
  end
end
