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

    ##
    # The instance of AnkiRecord::AnkiPackage that this collection object belongs to
    attr_reader :anki_package

    ##
    # The id attribute will become, or is the same as, the primary key id of this record in the database
    #
    # Since there should be only one col record, this attribute should be 1
    attr_reader :id

    ##
    # The time in milliseconds that the col record was created since the 1970 epoch
    attr_reader :creation_timestamp

    ##
    # The last time that the col record was modified in milliseconds since the 1970 epoch
    attr_reader :last_modified_time

    ##
    # An array of the collection's note type objects, which are instances of AnkiRecord::NoteType
    attr_reader :note_types

    ##
    # An array of the collection's deck objects, which are instances of AnkiRecord::Deck
    attr_reader :decks

    ##
    # An array of the collection's deck options group objects, which are instances of AnkiRecord::DeckOptionsGroup
    #
    # These represent groups of settings that can be applied to a deck.
    attr_reader :deck_options_groups

    ##
    # Instantiates the collection object for the +anki_package+
    #
    # The collection object represents the single record of the collection.anki21 database col table.
    #
    # This record stores the note types used by the notes and the decks that they belong to.
    def initialize(anki_package:)
      setup_collection_instance_variables(anki_package: anki_package)
    end

    private

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def setup_collection_instance_variables(anki_package:)
        @anki_package = anki_package
        @id = col_record["id"]
        @creation_timestamp = col_record["crt"]
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
        @deck_options_groups = JSON.parse(col_record["dconf"]).values.map do |dconf_hash|
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
