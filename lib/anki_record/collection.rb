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
    # The Anki Package object that the collection object belongs to
    attr_reader :anki_package

    ##
    # The id of the collection record the collection object corresponds to (should be 1 normally)
    attr_reader :id

    ##
    # The number of milliseconds that passed since the 1970 epoch when the collection record was created
    attr_reader :creation_timestamp

    ##
    # The number of milliseconds that passed since the 1970 epoch since the collection record was modified
    attr_reader :last_modified_time

    ##
    # The array of the collection object's note type objects
    attr_reader :note_types

    ##
    # The array of the collection object's deck objects
    attr_reader :decks

    ##
    # The array of the collection's deck options group objects.
    # These represent groups of settings that can be applied to decks.
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

    def add(note_type: nil, deck: nil, deck_options_group: nil) # :nodoc:
      raise ArgumentError unless note_type || deck || deck_options_group # TODO: RSpec examples

      @note_types << note_type if note_type
      @decks << deck if deck
      @deck_options_groups << deck_options_group if deck_options_group
    end

    ##
    # Returns the collection object's note type with name +name+ or nil if it is not found
    def find_note_type_by(name: nil)
      note_types.find { |note_type| note_type.name == name }
    end

    ##
    # Returns the collection object's deck with name +name+ or nil if it is not found
    def find_deck_by(name: nil)
      decks.find { |deck| deck.name == name }
    end

    private

      def setup_collection_instance_variables(anki_package:)
        @anki_package = anki_package
        setup_simple_collaborator_objects
        setup_custom_collaborator_objects
        remove_instance_variable(:@col_record)
      end

      def col_record
        @col_record ||= @anki_package.execute("select * from col;").first
      end

      # rubocop:disable Metrics/AbcSize
      def setup_simple_collaborator_objects
        @id = col_record["id"]
        @creation_timestamp = col_record["crt"]
        @last_modified_time = col_record["mod"]
        @scm = col_record["scm"]
        @ver = col_record["ver"]
        @dty = col_record["dty"]
        @usn = col_record["usn"]
        @ls = col_record["ls"]
        @configuration = JSON.parse(col_record["conf"])
        @tags = JSON.parse(col_record["tags"])
      end
      # rubocop:enable Metrics/AbcSize

      def setup_custom_collaborator_objects
        setup_note_type_collaborators
        setup_deck_collaborators
        setup_deck_options_groups_collaborators
      end

      def setup_note_type_collaborators
        @note_types = []
        JSON.parse(col_record["models"]).values.map do |model_hash|
          NoteType.new(collection: self, args: model_hash)
        end
      end

      def setup_deck_collaborators
        @decks = []
        JSON.parse(col_record["decks"]).values.map do |deck_hash|
          Deck.new(collection: self, args: deck_hash)
        end
      end

      def setup_deck_options_groups_collaborators
        @deck_options_groups = []
        JSON.parse(col_record["dconf"]).values.map do |dconf_hash|
          DeckOptionsGroup.new(collection: self, args: dconf_hash)
        end
      end
  end
end
