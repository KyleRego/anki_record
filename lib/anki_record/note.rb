# frozen_string_literal: true

require "pry"
require "securerandom"

require_relative "helpers/checksum_helper"
require_relative "helpers/time_helper"

module AnkiRecord
  ##
  # Represents an Anki note
  class Note
    include ChecksumHelper
    include TimeHelper
    include SharedConstantsHelper

    ##
    # The id of the note
    attr_reader :id

    ##
    # The globally unique id of the note
    attr_reader :guid

    ##
    # The last time the note was modified in seconds since the 1970 epoch
    attr_reader :last_modified_time

    ##
    # The note's update sequence number
    attr_reader :usn

    ##
    # The note's tags as an array
    attr_reader :tags

    ##
    # The note's field contents as a hash
    attr_reader :field_contents

    ##
    # The deck that the note's cards will be put into when saved
    attr_reader :deck

    ##
    # The note type of the note
    attr_reader :note_type

    ##
    # The collection object
    attr_reader :collection # TODO: tests

    ##
    # An array of the card objects of the note
    attr_reader :cards

    ##
    # flags corresponds to the flags column in the collection.anki21 notes table
    attr_reader :flags

    ##
    # data corresponds to the data column in the collection.anki21 notes table
    attr_reader :data

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def initialize(note_type: nil, deck: nil, collection: nil, data: nil)
      if note_type && deck && collection.nil? && data.nil? && (note_type.collection == deck.collection)
        setup_instance_variables(note_type: note_type, deck: deck)
      elsif collection && data
        setup_instance_variables_from_existing(collection: collection,
                                               note_data: data[:note_data], cards_data: data[:cards_data])
      else
        raise ArgumentError
      end
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity

    private

      # rubocop:disable Metrics/MethodLength
      def setup_instance_variables(note_type:, deck:)
        @note_type = note_type
        @deck = deck
        @collection = deck.collection
        @id = milliseconds_since_epoch
        @guid = globally_unique_id
        @last_modified_time = seconds_since_epoch
        @usn = NEW_OBJECT_USN
        @tags = []
        @field_contents = setup_field_contents
        @cards = @note_type.card_templates.map do |card_template|
          Card.new(note: self, card_template: card_template)
        end
        @flags = 0
        @data = ""
      end

      # rubocop:disable Metrics/AbcSize
      def setup_instance_variables_from_existing(collection:, note_data:, cards_data:)
        @collection = collection
        @note_type = collection.find_note_type_by id: note_data["mid"]
        @id = note_data["id"]
        @guid = note_data["guid"]
        @last_modified_time = note_data["mod"]
        @usn = note_data["usn"]
        @tags = note_data["tags"].split
        snake_case_field_names_in_order = note_type.snake_case_field_names
        @field_contents = setup_field_contents
        note_data["flds"].split("\x1F").each_with_index do |fld, ordinal|
          @field_contents[snake_case_field_names_in_order[ordinal]] = fld
        end
        @cards = @note_type.card_templates.map.with_index do |_card_template, index|
          Card.new(note: self, card_data: cards_data[index])
        end
        @flags = note_data["flags"]
        @data = note_data["data"]
      end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    public

    ##
    # Save the note to the collection.anki21 database
    def save
      @collection.anki_package.execute <<~SQL
        insert into notes (id, guid, mid, mod,
                          usn, tags, flds, sfld,
                          csum, flags, data)
                    values ('#{@id}', '#{@guid}', '#{note_type.id}', '#{@last_modified_time}',
                          '#{@usn}', '#{@tags.join(" ")}', '#{field_values_separated_by_us}', '#{sort_field_value}',
                          '#{checksum(sort_field_value)}', '#{@flags}', '#{@data}')
      SQL
      cards.each(&:save)
      true
    end

    ##
    # This overrides BasicObject#method_missing and has the effect of creating "ghost methods"
    #
    # Specifically, creates setter and getter ghost methods for the fields of the note's note type
    def method_missing(method_name, field_content = nil)
      method_name = method_name.to_s
      return @field_contents[method_name] unless method_name.end_with?("=")

      method_name = method_name.chomp("=")
      valid_fields_snake_names = @field_contents.keys
      unless valid_fields_snake_names.include?(method_name)
        raise ArgumentError,
              "Valid fields for the #{note_type.name} note type are one of #{valid_fields_snake_names.join(", ")}"
      end

      @field_contents[method_name] = field_content
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

      def setup_field_contents
        field_contents = {}
        note_type.snake_case_field_names.each do |field_name|
          field_contents[field_name] = ""
        end
        field_contents
      end

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
