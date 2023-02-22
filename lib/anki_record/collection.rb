# frozen_string_literal: true

require "pry"
require "json"

require_relative "deck"
require_relative "deck_options_group"
require_relative "helpers/time_helper"
require_relative "note_type"

module AnkiRecord
  ##
  # Collection represents the single record in the Anki database `col` table
  class Collection
    include AnkiRecord::TimeHelper

    attr_reader :note_types, :decks

    def initialize(anki_package:)
      setup_collection_instance_variables(anki_package: anki_package)
    end

    private

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def setup_collection_instance_variables(anki_package:)
        @anki_package = anki_package
        @id = col_record["id"]
        @crt = col_record["crt"]
        @last_modified_time = (mod = col_record["mod"]).zero? ? milliseconds_since_epoch : mod
        @scm = col_record["scm"]
        @ver = col_record["ver"]
        @dty = col_record["dty"]
        @usn = col_record["usn"]
        @ls = col_record["ls"]
        @configuration = JSON.parse(col_record["conf"])
        @note_types = JSON.parse(col_record["models"]).values.map do |model_hash|
          NoteType.new(collection: self, args: model_hash)
        end
        @decks = JSON.parse(col_record["decks"]).values.map do |deck_hash|
          Deck.new(collection: self, args: deck_hash)
        end
        @deck_option_groups = JSON.parse(col_record["dconf"]).values.map do |dconf_hash|
          DeckOptionsGroup.new(collection: self, args: dconf_hash)
        end
        @tags = JSON.parse(col_record["tags"])
        remove_instance_variable(:@col_record)
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      def col_record
        @col_record ||= @anki_package.execute("select * from col;").first
      end
  end
end
