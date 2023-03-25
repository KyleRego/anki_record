# frozen_string_literal: true

require "securerandom"

require_relative "helpers/checksum_helper"
require_relative "helpers/time_helper"

# rubocop:disable Metrics/ClassLength
module AnkiRecord
  ##
  # Represents an Anki note. The note object corresponds to a record in the `notes`
  # table in the collection.anki21 database.
  class Note
    include ChecksumHelper
    include TimeHelper
    include SharedConstantsHelper

    ##
    # The note's id.
    attr_reader :id

    ##
    # The note's globally unique id.
    attr_reader :guid

    ##
    # The number of seconds since the 1970 epoch at which the note was last modified.
    attr_reader :last_modified_timestamp

    ##
    # The note's update sequence number.
    attr_reader :usn

    ##
    # The note's tags, as an array. The tags are strings.
    attr_reader :tags

    ##
    # The note's field contents, as a hash.
    attr_reader :field_contents

    ##
    # The note's deck object.
    #
    # When the note is saved, the cards will belong to this deck.
    attr_reader :deck

    ##
    # The note's note type object.
    attr_reader :note_type

    ##
    # The note's collection object.
    attr_reader :collection

    ##
    # The note's card objects, as an array.
    attr_reader :cards

    ##
    # Corresponds to the flags column in the collection.anki21 notes table.
    attr_reader :flags

    ##
    # Corresponds to the data column in the collection.anki21 notes table.
    attr_reader :data

    ##
    # Instantiates a note of type +note_type+ and belonging to deck +deck+.
    #
    # If +note_type+ and +deck+ arguments are used, +collection+ and +data should not be given.
    def initialize(note_type: nil, deck: nil, collection: nil, data: nil)
      if note_type && deck
        setup_instance_variables_for_new_note(note_type: note_type, deck: deck)
      elsif collection && data
        setup_instance_variables_from_existing(collection: collection,
                                               note_data: data[:note_data], cards_data: data[:cards_data])
      else
        raise ArgumentError
      end
    end

    private

      def setup_instance_variables_for_new_note(note_type:, deck:)
        raise ArgumentError unless note_type.collection == deck.collection

        setup_collaborator_object_instance_variables_for_new_note(note_type: note_type, deck: deck)
        setup_simple_instance_variables_for_new_note
      end

      def setup_collaborator_object_instance_variables_for_new_note(note_type:, deck:)
        @note_type = note_type
        @deck = deck
        @collection = deck.collection
        @field_contents = setup_empty_field_contents_hash
        @cards = @note_type.card_templates.map do |card_template|
          Card.new(note: self, card_template: card_template)
        end
      end

      def setup_simple_instance_variables_for_new_note
        @id = milliseconds_since_epoch
        @guid = globally_unique_id
        @last_modified_timestamp = seconds_since_epoch
        @usn = NEW_OBJECT_USN
        @tags = []
        @flags = 0
        @data = ""
      end

      def setup_instance_variables_from_existing(collection:, note_data:, cards_data:)
        setup_collaborator_object_instance_variables_from_existing(collection: collection, note_data: note_data,
                                                                   cards_data: cards_data)
        setup_simple_instance_variables_from_existing(note_data: note_data)
      end

      def setup_collaborator_object_instance_variables_from_existing(collection:, note_data:, cards_data:)
        @collection = collection
        @note_type = collection.find_note_type_by id: note_data["mid"]
        @field_contents = setup_field_contents_hash_from_existing(note_data: note_data)
        @cards = @note_type.card_templates.map.with_index do |_card_template, index|
          Card.new(note: self, card_data: cards_data[index])
        end
      end

      def setup_field_contents_hash_from_existing(note_data:)
        field_contents = setup_empty_field_contents_hash
        snake_case_field_names_in_order = note_type.snake_case_field_names
        note_data["flds"].split("\x1F").each_with_index do |fld, ordinal|
          field_contents[snake_case_field_names_in_order[ordinal]] = fld
        end
        field_contents
      end

      def setup_simple_instance_variables_from_existing(note_data:)
        @id = note_data["id"]
        @guid = note_data["guid"]
        @last_modified_timestamp = note_data["mod"]
        @usn = note_data["usn"]
        @tags = note_data["tags"].split
        @flags = note_data["flags"]
        @data = note_data["data"]
      end

      def setup_empty_field_contents_hash
        field_contents = {}
        note_type.snake_case_field_names.each { |field_name| field_contents[field_name] = "" }
        field_contents
      end

    public

    ##
    # Saves the note to the collection.anki21 database.
    #
    # This also saves the note's cards.
    def save
      collection.find_note_by(id: @id) ? update_note_in_collection_anki21 : insert_new_note_in_collection_anki21
      true
    end

    private

      def update_note_in_collection_anki21
        statement = @collection.anki_package.prepare <<~SQL
          update notes set guid = ?, mid = ?, mod = ?, usn = ?, tags = ?,
                                      flds = ?, sfld = ?, csum = ?, flags = ?, data = ? where id = ?
        SQL
        statement.execute([@guid, note_type.id, @last_modified_timestamp,
                           @usn, @tags.join(" "), field_values_separated_by_us, sort_field_value,
                           checksum(sort_field_value), @flags, @data, @id])
        cards.each { |card| card.save(note_exists_already: true) }
      end

      def insert_new_note_in_collection_anki21
        statement = @collection.anki_package.prepare <<~SQL
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
    # This allows #respond_to? to be accurate for the ghost methods created by #method_missing
    def respond_to_missing?(method_name, *)
      method_name = method_name.to_s
      if method_name.end_with?("=")
        note_type.snake_case_field_names.include?(method_name.chomp("="))
      else
        note_type.snake_case_field_names.include?(method_name)
      end
    end

    private

      def globally_unique_id
        SecureRandom.uuid.slice(5...15)
      end

      def field_values_separated_by_us
        # The ASCII control code represented by hexadecimal 1F is the Unit Separator (US)
        note_type.snake_case_field_names.map { |field_name| @field_contents[field_name] }.join("\x1F")
      end

      def sort_field_value
        @field_contents[note_type.snake_case_sort_field_name]
      end
  end
end
# rubocop:enable Metrics/ClassLength
