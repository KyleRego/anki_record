# frozen_string_literal: true

require "securerandom"

require_relative "../helpers/anki_guid_helper"
require_relative "../helpers/checksum_helper"
require_relative "../helpers/time_helper"
require_relative "note_attributes"

module AnkiRecord
  ##
  # Represents an Anki note.
  class Note
    include Helpers::ChecksumHelper
    include NoteAttributes
    include Helpers::TimeHelper
    include Helpers::SharedConstantsHelper

    ##
    # Instantiates a note of type +note_type+ and belonging to deck +deck+.
    def initialize(note_type: nil, deck: nil, anki21_database: nil, data: nil)
      if note_type && deck
        setup_new_note(note_type:, deck:)
      elsif anki21_database && data
        setup_existing_note(anki21_database:,
                            note_data: data[:note_data], cards_data: data[:cards_data])
      else
        raise ArgumentError
      end
    end

    ##
    # Saves the note and its cards.
    def save
      anki21_database.find_note_by(id: @id) ? update_note_in_collection_anki21 : insert_new_note_in_collection_anki21
      true
    end

    private

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def setup_new_note(note_type:, deck:)
        raise ArgumentError unless note_type.anki21_database == deck.anki21_database

        @note_type = note_type
        @deck = deck
        @anki21_database = note_type.anki21_database
        @field_contents = setup_empty_field_contents_hash
        @cards = @note_type.card_templates.map do |card_template|
          Card.new(note: self, card_template:)
        end
        @id = milliseconds_since_epoch
        @guid = Helpers::AnkiGuidHelper.globally_unique_id
        @last_modified_timestamp = seconds_since_epoch
        @usn = NEW_OBJECT_USN
        @tags = []
        @flags = 0
        @data = ""
      end

      def setup_existing_note(anki21_database:, note_data:, cards_data:)
        @anki21_database = anki21_database
        @note_type = anki21_database.find_note_type_by id: note_data["mid"]
        @field_contents = setup_field_contents_hash_from_existing(note_data:)
        @cards = @note_type.card_templates.map.with_index do |_card_template, index|
          Card.new(note: self, card_data: cards_data[index])
        end
        @id = note_data["id"]
        @guid = note_data["guid"]
        @last_modified_timestamp = note_data["mod"]
        @usn = note_data["usn"]
        @tags = note_data["tags"].split
        @flags = note_data["flags"]
        @data = note_data["data"]
      end

      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      def setup_field_contents_hash_from_existing(note_data:)
        field_contents = setup_empty_field_contents_hash
        snake_case_field_names_in_order = note_type.snake_case_field_names
        note_data["flds"].split("\x1F").each_with_index do |fld, ordinal|
          field_contents[snake_case_field_names_in_order[ordinal]] = fld
        end
        field_contents
      end

      def setup_empty_field_contents_hash
        field_contents = {}
        note_type.snake_case_field_names.each { |field_name| field_contents[field_name] = "" }
        field_contents
      end

      def update_note_in_collection_anki21
        statement = anki21_database.prepare <<~SQL
          update notes set guid = ?, mid = ?, mod = ?, usn = ?, tags = ?,
                                      flds = ?, sfld = ?, csum = ?, flags = ?, data = ? where id = ?
        SQL
        statement.execute([@guid, note_type.id, @last_modified_timestamp,
                           @usn, @tags.join(" "), field_values_separated_by_us, sort_field_value,
                           checksum(sort_field_value), @flags, @data, @id])
        cards.each { |card| card.save(note_exists_already: true) }
      end

      def insert_new_note_in_collection_anki21
        statement = anki21_database.prepare <<~SQL
          insert into notes (id, guid, mid, mod, usn, tags, flds, sfld, csum, flags, data)
                      values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        SQL
        statement.execute([@id, @guid, note_type.id, @last_modified_timestamp,
                           @usn, @tags.join(" "), field_values_separated_by_us, sort_field_value,
                           checksum(sort_field_value), @flags, @data])
        cards.each(&:save)
      end

    public

    ##
    # Overrides BasicObject#method_missing and creates "ghost methods".
    #
    # The ghost methods are the setters and getters for the note field values.
    def method_missing(method_name, field_content = nil)
      raise NoMethodError, "##{method_name} is not defined or a ghost method" unless respond_to_missing? method_name

      method_name = method_name.to_s
      return @field_contents[method_name] unless method_name.end_with?("=")

      @field_contents[method_name.chomp("=")] = field_content
    end

    ##
    # This allows #respond_to? to be accurate for the ghost methods created by #method_missing.
    def respond_to_missing?(method_name, *)
      method_name = method_name.to_s
      if method_name.end_with?("=")
        note_type.snake_case_field_names.include?(method_name.chomp("="))
      else
        note_type.snake_case_field_names.include?(method_name)
      end
    end

    private

      def field_values_separated_by_us
        # The ASCII control code represented by hexadecimal 1F is the Unit Separator (US)
        note_type.snake_case_field_names.map { |field_name| @field_contents[field_name] }.join("\x1F")
      end

      def sort_field_value
        @field_contents[note_type.snake_case_sort_field_name]
      end
  end
end
