# frozen_string_literal: true

module AnkiRecord
  ##
  # Anki21Database represents a collection.anki21 Anki SQLite database.
  class Anki21Database
    ##
    # The collection's note type objects as an array.
    attr_reader :note_types

    ##
    # The collection's deck objects as an array
    attr_reader :decks

    ##
    # The collection's deck option group objects as an array.
    attr_reader :deck_options_groups

    attr_reader :anki_package, :collection, :database

    FILENAME = "collection.anki21"

    def initialize(anki_package:)
      @anki_package = anki_package
      @database = SQLite3::Database.new "#{anki_package.tmpdir}/#{FILENAME}", options: {}
      database.execute_batch ANKI_SCHEMA_DEFINITION
      database.execute INSERT_COLLECTION_ANKI_21_COL_RECORD
      database.results_as_hash = true
      @collection = Collection.new(anki21_database: self)
      initialize_note_types
      initialize_deck_options_groups
      initialize_decks
    end

    # Returns an SQLite3::Statement object to be executed against the collection.anki21 database.
    #
    # Statement#execute executes the statement.
    def prepare(sql)
      database.prepare sql
    end

    ##
    # Returns the note found by +id+, or nil if it is not found.
    def find_note_by(id:)
      note_cards_data = note_cards_data_for_note_id(id:)
      return nil unless note_cards_data

      AnkiRecord::Note.new(anki21_database: self, data: note_cards_data)
    end

    # :nodoc:
    def decks_json
      JSON.parse(prepare("select decks from col;").execute.first["decks"])
    end

    # :nodoc:
    def models_json
      JSON.parse(prepare("select models from col;").execute.first["models"])
    end

    def col_record
      @col_record ||= prepare("select * from col").execute.first
    end

    # :nodoc:
    def add_note_type(note_type)
      raise ArgumentError unless note_type.instance_of?(AnkiRecord::NoteType)

      existing_note_type = nil
      note_types.each do |nt|
        existing_note_type = nt if nt.id == note_type.id
      end
      note_types.delete(existing_note_type) if existing_note_type

      note_types << note_type
    end

    # :nodoc:
    def add_deck(deck)
      raise ArgumentError unless deck.instance_of?(AnkiRecord::Deck)

      decks << deck
    end

    # :nodoc:
    def add_deck_options_group(deck_options_group)
      raise ArgumentError unless deck_options_group.instance_of?(AnkiRecord::DeckOptionsGroup)

      deck_options_groups << deck_options_group
    end

    ##
    # Returns the note type found by either +name+ or +id+, or nil if it is not found.
    def find_note_type_by(name: nil, id: nil)
      if (id && name) || (id.nil? && name.nil?)
        raise ArgumentError,
              "You must pass either an id or name keyword argument."
      end

      name ? find_note_type_by_name(name:) : find_note_type_by_id(id:)
    end

    ##
    # Returns the deck found by either +name+ or +id+, or nil if it is not found.
    def find_deck_by(name: nil, id: nil)
      if (id && name) || (id.nil? && name.nil?)
        raise ArgumentError,
              "You must pass either an id or name keyword argument."
      end

      name ? find_deck_by_name(name:) : find_deck_by_id(id:)
    end

    ##
    # Returns the deck options group object found by +id+, or nil if it is not found.
    def find_deck_options_group_by(id:)
      deck_options_groups.find { |deck_options_group| deck_options_group.id == id }
    end

    private

      def find_note_type_by_name(name:)
        note_types.find { |note_type| note_type.name == name }
      end

      def find_note_type_by_id(id:)
        note_types.find { |note_type| note_type.id == id }
      end

      def find_deck_by_name(name:)
        decks.find { |deck| deck.name == name }
      end

      def find_deck_by_id(id:)
        decks.find { |deck| deck.id == id }
      end

      def note_cards_data_for_note_id(id:)
        note_data = prepare("select * from notes where id = ?").execute([id]).first
        return nil unless note_data

        cards_data = prepare("select * from cards where nid = ?").execute([id]).to_a
        { note_data:, cards_data: }
      end

      def initialize_note_types
        @note_types = []
        JSON.parse(col_record["models"]).values.map do |model_hash|
          NoteType.new(anki21_database: self, args: model_hash)
        end
      end

      def initialize_decks
        @decks = []
        JSON.parse(col_record["decks"]).values.map do |deck_hash|
          Deck.new(anki21_database: self, args: deck_hash)
        end
      end

      def initialize_deck_options_groups
        @deck_options_groups = []
        JSON.parse(col_record["dconf"]).values.map do |dconf_hash|
          DeckOptionsGroup.new(anki21_database: self, args: dconf_hash)
        end
      end
  end
end
