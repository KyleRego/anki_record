# frozen_string_literal: true

require "pry"
require "json"

require_relative "deck"
require_relative "deck_options_group"
require_relative "helpers/data_query_helper"
require_relative "helpers/time_helper"
require_relative "note_type"

module AnkiRecord
  ##
  # Collection represents the single record in the Anki collection.anki21 database's `col` table.
  # The note types, decks, and deck options groups data are contained within this record.
  class Collection
    include AnkiRecord::DataQueryHelper
    include AnkiRecord::TimeHelper

    ##
    # The collection's Anki package object.
    attr_reader :anki_package

    ##
    # The collection's id, and the id of the corresponding col record (usually 1).
    attr_reader :id

    ##
    # The number of milliseconds that passed since the 1970 epoch when the collection record was created
    attr_reader :created_at_timestamp

    ##
    # The number of milliseconds that passed since the 1970 epoch since the collection record was modified
    attr_reader :last_modified_timestamp

    ##
    # The collection's note type objects as an array.
    attr_reader :note_types

    ##
    # The collection's deck objects as an array
    attr_reader :decks

    ##
    # The collection's deck option group objects as an array.
    attr_reader :deck_options_groups

    def initialize(anki_package:) # :nodoc:
      setup_collection_instance_variables(anki_package: anki_package)
    end

    def add_note_type(note_type) # :nodoc:
      raise ArgumentError unless note_type.instance_of?(AnkiRecord::NoteType)

      @note_types << note_type
    end

    def add_deck(deck) # :nodoc:
      raise ArgumentError unless deck.instance_of?(AnkiRecord::Deck)

      @decks << deck
    end

    def add_deck_options_group(deck_options_group) # :nodoc:
      raise ArgumentError unless deck_options_group.instance_of?(AnkiRecord::DeckOptionsGroup)

      @deck_options_groups << deck_options_group
    end

    ##
    # Returns the collection's note type object found by either +name+ or +id+, or nil if it is not found.
    def find_note_type_by(name: nil, id: nil)
      return note_types.find { |note_type| note_type.name == name } if name && id.nil?

      return note_types.find { |note_type| note_type.id == id } if id && name.nil?

      raise ArgumentError
    end

    ##
    # Returns the collection's deck object found by either +name+ or +id+, or nil if it is not found.
    def find_deck_by(name: nil, id: nil)
      return decks.find { |deck| deck.name == name } if name && id.nil?

      return decks.find { |deck| deck.id == id } if id && name.nil?

      raise ArgumentError
    end

    ##
    # Returns the collection's deck options group object found by +id+, or nil if it is not found.
    def find_deck_options_group_by(id:)
      deck_options_groups.find { |deck_options_group| deck_options_group.id == id }
    end

    ##
    # Returns the collection's note object found by +id+, or nil if it is not found.
    def find_note_by(id:)
      note_cards_data = note_cards_data_for_note_id sql_able: anki_package, id: id
      return nil unless note_cards_data

      AnkiRecord::Note.new collection: self, data: note_cards_data
    end

    def decks_json # :nodoc:
      JSON.parse(anki_package.prepare("select decks from col;").execute.first["decks"])
    end

    def models_json # :nodoc:
      JSON.parse(anki_package.prepare("select models from col;").execute.first["models"])
    end

    def copy_over_existing(col_record:) # :nodoc:
      @col_record = col_record
      setup_simple_collaborator_objects
      setup_custom_collaborator_objects
      remove_instance_variable(:@col_record)
    end

    private

      def setup_collection_instance_variables(anki_package:)
        @anki_package = anki_package
        setup_simple_collaborator_objects
        setup_custom_collaborator_objects
        remove_instance_variable(:@col_record)
      end

      def col_record
        @col_record ||= @anki_package.prepare("select * from col").execute.first
      end

      # rubocop:disable Metrics/AbcSize
      def setup_simple_collaborator_objects
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
      end
      # rubocop:enable Metrics/AbcSize

      def setup_custom_collaborator_objects
        setup_note_type_collaborators
        setup_deck_options_groups_collaborators
        setup_deck_collaborators
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
