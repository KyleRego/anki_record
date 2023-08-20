# frozen_string_literal: true

require_relative "anki21_database_attributes"
require_relative "anki21_database_constructors"

module AnkiRecord
  ##
  # Anki21Database represents the collection.anki21 Anki SQLite database in the Anki Package
  class Anki21Database
    include Anki21DatabaseAttributes
    include Anki21DatabaseConstructors

    def self.create_new(anki_package:) # :nodoc:
      anki21_database = new
      anki21_database.create_initialize(anki_package:)
      anki21_database
    end

    def self.update_new(anki_package:) # :nodoc:
      anki21_database = new
      anki21_database.update_initialize(anki_package:)
      anki21_database
    end

    ##
    # Returns an SQLite3::Statement object (sqlite3 gem) to be executed against the collection.anki21 database.
    #
    # Statement#execute executes the statement.
    def prepare(sql)
      database.prepare sql
    end

    # rubocop:disable Metrics/MethodLength
    ##
    # Returns the note found by either +sfld" or +id+, or nil if it is not found.
    def find_note_by(sfld: nil, id: nil)
      if (id && sfld) || (id.nil? && sfld.nil?)
        raise ArgumentError,
              "You must pass either an id or sfld keyword argument to find_note_by."
      end
      note_cards_data = if id
                          note_cards_data_for_note(id:)
                        else
                          note_cards_data_for_note(sfld:)
                        end
      return nil unless note_cards_data

      AnkiRecord::Note.new(anki21_database: self, data: note_cards_data)
    end
    # rubocop:enable Metrics/MethodLength

    ##
    # Returns an array of notes that have any field value matching +text+
    def find_notes_by_exact_text_match(text:)
      return [] if text == ""

      like_matcher = "%#{text}%"
      note_datas = prepare("select * from notes where flds LIKE ?").execute([like_matcher])

      note_datas.map do |note_data|
        id = note_data["id"]

        cards_data = prepare("select * from cards where nid = ?").execute([id]).to_a
        note_cards_data = { note_data:, cards_data: }

        AnkiRecord::Note.new(anki21_database: self, data: note_cards_data)
      end
    end

    ##
    # Returns the note type found by either +name+ or +id+, or nil if it is not found.
    def find_note_type_by(name: nil, id: nil)
      if (id && name) || (id.nil? && name.nil?)
        raise ArgumentError,
              "You must pass either an id or name keyword argument to find_note_type_by."
      end

      name ? find_note_type_by_name(name:) : find_note_type_by_id(id:)
    end

    ##
    # Returns the deck found by either +name+ or +id+, or nil if it is not found.
    def find_deck_by(name: nil, id: nil)
      if (id && name) || (id.nil? && name.nil?)
        raise ArgumentError,
              "You must pass either an id or name keyword argument to find_deck_by."
      end

      name ? find_deck_by_name(name:) : find_deck_by_id(id:)
    end

    ##
    # Returns the deck options group object found by +id+, or nil if it is not found.
    def find_deck_options_group_by(id:)
      deck_options_groups.find { |deck_options_group| deck_options_group.id == id }
    end

    def decks_json # :nodoc:
      JSON.parse(prepare("select decks from col;").execute.first["decks"])
    end

    def models_json # :nodoc:
      JSON.parse(prepare("select models from col;").execute.first["models"])
    end

    def col_record # :nodoc:
      prepare("select * from col").execute.first
    end

    def add_note_type(note_type) # :nodoc:
      raise ArgumentError unless note_type.instance_of?(AnkiRecord::NoteType)

      existing_note_type = nil
      note_types.each do |nt|
        existing_note_type = nt if nt.id == note_type.id
      end
      note_types.delete(existing_note_type) if existing_note_type

      note_types << note_type
    end

    def add_deck(deck) # :nodoc:
      raise ArgumentError unless deck.instance_of?(AnkiRecord::Deck)

      decks << deck
    end

    def add_deck_options_group(deck_options_group) # :nodoc:
      raise ArgumentError unless deck_options_group.instance_of?(AnkiRecord::DeckOptionsGroup)

      deck_options_groups << deck_options_group
    end

    # :nocov:
    def inspect # :nodoc:
      "[= Anki21Database of package with name #{package.name} =]"
    end
    # :nocov:

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

      def note_cards_data_for_note(id: nil, sfld: nil)
        note_data = if id
                      prepare("select * from notes where id = ?").execute([id]).first
                    elsif sfld
                      prepare("select * from notes where sfld = ?").execute([sfld]).first
                    end
        return nil unless note_data

        id ||= note_data["id"]

        cards_data = prepare("select * from cards where nid = ?").execute([id]).to_a
        { note_data:, cards_data: }
      end
  end
end
