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
  # The note types, decks, and deck options groups data are contained within this record.
  class Collection
    include Helpers::TimeHelper
    include CollectionAttributes

    attr_reader :anki21_database

    # :nodoc:
    def initialize(anki21_database:)
      setup_collection_instance_variables(anki21_database:)
    end

    # :nodoc:
    def add_note_type(note_type)
      raise ArgumentError unless note_type.instance_of?(AnkiRecord::NoteType)

      existing_note_type = nil
      @note_types.each do |nt|
        existing_note_type = nt if nt.id == note_type.id
      end
      @note_types.delete(existing_note_type) if existing_note_type

      @note_types << note_type
    end

    # :nodoc:
    def add_deck(deck)
      raise ArgumentError unless deck.instance_of?(AnkiRecord::Deck)

      @decks << deck
    end

    # :nodoc:
    def add_deck_options_group(deck_options_group)
      raise ArgumentError unless deck_options_group.instance_of?(AnkiRecord::DeckOptionsGroup)

      @deck_options_groups << deck_options_group
    end

    ##
    # Returns the collection's note type object found by either +name+ or +id+, or nil if it is not found.
    def find_note_type_by(name: nil, id: nil)
      if (id && name) || (id.nil? && name.nil?)
        raise ArgumentError,
              "You must pass either an id or name keyword argument."
      end

      name ? find_note_type_by_name(name:) : find_note_type_by_id(id:)
    end

    private

      def find_note_type_by_name(name:)
        note_types.find { |note_type| note_type.name == name }
      end

      def find_note_type_by_id(id:)
        note_types.find { |note_type| note_type.id == id }
      end

    public

    ##
    # Returns the collection's deck object found by either +name+ or +id+, or nil if it is not found.
    def find_deck_by(name: nil, id: nil)
      if (id && name) || (id.nil? && name.nil?)
        raise ArgumentError,
              "You must pass either an id or name keyword argument."
      end

      name ? find_deck_by_name(name:) : find_deck_by_id(id:)
    end

    private

      def find_deck_by_name(name:)
        decks.find { |deck| deck.name == name }
      end

      def find_deck_by_id(id:)
        decks.find { |deck| deck.id == id }
      end

    public

    ##
    # Returns the collection's deck options group object found by +id+, or nil if it is not found.
    def find_deck_options_group_by(id:)
      deck_options_groups.find { |deck_options_group| deck_options_group.id == id }
    end

    # :nodoc:
    def decks_json
      JSON.parse(anki21_database.prepare("select decks from col;").execute.first["decks"])
    end

    # :nodoc:
    def models_json
      JSON.parse(anki21_database.prepare("select models from col;").execute.first["models"])
    end

    def copy_over_existing(col_record:) # :nodoc:
      @col_record = col_record
      setup_simple_collaborator_objects
      setup_custom_collaborator_objects
      remove_instance_variable(:@col_record)
    end

    private

      def setup_collection_instance_variables(anki21_database:)
        @anki21_database = anki21_database
        setup_simple_collaborator_objects
        setup_custom_collaborator_objects
        remove_instance_variable(:@col_record)
      end

      def col_record
        @col_record ||= @anki21_database.prepare("select * from col").execute.first
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
