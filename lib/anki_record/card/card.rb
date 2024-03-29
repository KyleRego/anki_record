# frozen_string_literal: true

require_relative "../helpers/shared_constants_helper"
require_relative "../helpers/time_helper"
require_relative "card_attributes"

module AnkiRecord
  ##
  # Card represents an Anki card. The cards are indirectly created when creating notes.
  class Card
    include CardAttributes
    include Helpers::TimeHelper
    include Helpers::SharedConstantsHelper

    # :nodoc:

    def initialize(note:, card_template: nil, card_data: nil)
      @note = note
      if card_template
        setup_instance_variables_for_new_card(card_template:)
      elsif card_data
        setup_instance_variables_from_existing(card_data:)
      else
        raise ArgumentError
      end
    end

    def save(note_exists_already: false)
      note_exists_already ? update_card_in_collection_anki21 : insert_new_card_in_collection_anki21
    end

    private

      # rubocop:disable Metrics/MethodLength
      def setup_instance_variables_for_new_card(card_template:)
        raise ArgumentError unless @note.note_type == card_template.note_type

        @card_template = card_template
        @deck = @note.deck
        @anki21_database = @deck.anki21_database
        @id = milliseconds_since_epoch
        @last_modified_timestamp = seconds_since_epoch
        @usn = NEW_OBJECT_USN
        %w[type queue due ivl factor reps lapses left odue odid flags].each do |instance_variable_name|
          instance_variable_set "@#{instance_variable_name}", 0
        end
        @data = "{}"
      end
      # rubocop:enable Metrics/MethodLength

      def setup_instance_variables_from_existing(card_data:)
        @anki21_database = note.anki21_database
        @deck = anki21_database.find_deck_by id: card_data["did"]
        @card_template = note.note_type.card_templates.find do |card_template|
          card_template.ordinal_number == card_data["ord"]
        end
        @last_modified_timestamp = card_data["mod"]
        %w[id usn type queue due ivl factor reps lapses left odue odid flags data].each do |instance_variable_name|
          instance_variable_set "@#{instance_variable_name}", card_data[instance_variable_name]
        end
      end

      def update_card_in_collection_anki21
        statement = anki21_database.prepare <<~SQL
          update cards set nid = ?, did = ?, ord = ?, mod = ?, usn = ?, type = ?,
                            queue = ?, due = ?, ivl = ?, factor = ?, reps = ?, lapses = ?,
                            left = ?, odue = ?, odid = ?, flags = ?, data = ? where id = ?
        SQL
        statement.execute [@note.id, @deck.id, ordinal_number,
                           @last_modified_timestamp, @usn, @type, @queue,
                           @due, @ivl, @factor, @reps,
                           @lapses, @left, @odue, @odid, @flags, @data, @id]
      end

      def insert_new_card_in_collection_anki21
        statement = anki21_database.prepare <<~SQL
          insert into cards (id, nid, did, ord,
                            mod, usn, type, queue,
                            due, ivl, factor, reps,
                            lapses, left, odue, odid, flags, data)
                      values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        SQL
        statement.execute [@id, @note.id, @deck.id, ordinal_number,
                           @last_modified_timestamp, @usn, @type, @queue,
                           @due, @ivl, @factor, @reps, @lapses, @left, @odue, @odid, @flags, @data]
      end

      def ordinal_number
        @card_template&.ordinal_number
      end
  end
end
