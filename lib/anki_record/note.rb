# frozen_string_literal: true

require "pry"
require "securerandom"

require_relative "helpers/checksum_helper"
require_relative "helpers/time_helper"

module AnkiRecord
  ##
  # Note represents an Anki note
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
    # The tags applied to the note
    #
    # TODO: a setter method for the tags of the note
    attr_reader :tags

    ##
    # The deck that the note's cards will be put into when saved
    attr_reader :deck

    ##
    # The note type of the note
    attr_reader :note_type

    ##
    # The card objects of the note
    attr_reader :cards

    ##
    # Instantiate a new note for a deck and note type
    # or TODO: instantiate a new object from an already existing record
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def initialize(deck:, note_type:)
      raise ArgumentError unless deck && note_type && deck.collection == note_type.collection

      @apkg = deck.collection.anki_package

      @id = milliseconds_since_epoch
      @guid = globally_unique_id
      @last_modified_time = seconds_since_epoch
      @usn = NEW_OBJECT_USN
      @tags = []
      @deck = deck
      @note_type = note_type
      @field_contents = setup_field_contents
      @cards = @note_type.card_templates.map { |card_template| Card.new(note: self, card_template: card_template) }
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    ##
    # Save the note to the collection.anki21 database
    def save
      @apkg.execute <<~SQL
        insert into notes (id, guid, mid, mod, usn, tags, flds, sfld, csum, flags, data)
                    values ('#{@id}', '#{@guid}', '#{note_type.id}', '#{@last_modified_time}', '#{@usn}', '#{@tags.join(" ")}', '#{field_values_separated_by_us}', '#{sort_field_value}', '#{checksum(sort_field_value)}', '0', '')
      SQL
      cards.each(&:save)
      true
    end

    ##
    # This overrides BasicObject#method_missing and has the effect of creating "ghost methods"
    #
    # Specifically, creates setter and getter ghost methods for the fields of the note's note type
    #
    # TODO: This should raise a NoMethodError if
    # the missing method does not end with '=' and is not a field of the note type
    def method_missing(method_name, field_content = nil)
      method_name = method_name.to_s
      return @field_contents[method_name] unless method_name.end_with?("=")

      method_name = method_name.chomp("=")
      valid_fields_snake_names = @field_contents.keys
      unless valid_fields_snake_names.include?(method_name)
        raise ArgumentError, "Valid fields for this not type are one of #{valid_fields_snake_names.join(", ")}"
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
