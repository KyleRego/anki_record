# frozen_string_literal: true

require_relative "helpers/shared_constants_helper"
require_relative "helpers/time_helper"

module AnkiRecord
  ##
  # Card represents an Anki card.
  class Card
    include TimeHelper
    include SharedConstantsHelper

    ##
    # The card's note object.
    attr_reader :note

    ##
    # The card's deck object.
    attr_reader :deck

    ##
    # The card's collection object.
    attr_reader :collection

    ##
    # The card's card template object.
    attr_reader :card_template

    ##
    # The card's id.
    #
    # This is also the number of milliseconds since the 1970 epoch at which the card was created.
    attr_reader :id

    ##
    # The number of seconds since the 1970 epoch at which the card was last modified.
    attr_reader :last_modified_timestamp

    ##
    # The card's update sequence number.
    attr_reader :usn

    attr_reader :type, :queue, :due, :ivl, :factor, :reps, :lapses, :left, :odue, :odid, :flags, :data

    def initialize(note:, card_template: nil, card_data: nil) # :nodoc:
      @note = note
      if card_template
        setup_instance_variables_for_new_card(card_template: card_template)
      elsif card_data
        setup_instance_variables_from_existing(card_data: card_data)
      else
        raise ArgumentError
      end
    end

    private

      def setup_instance_variables_for_new_card(card_template:)
        raise ArgumentError unless @note.note_type == card_template.note_type

        setup_collaborator_object_instance_variables_for_new_card(card_template: card_template)
        setup_simple_instance_variables_for_new_card
      end

      def setup_collaborator_object_instance_variables_for_new_card(card_template:)
        @card_template = card_template
        @deck = @note.deck
        @collection = @deck.collection
      end

      def setup_simple_instance_variables_for_new_card
        @id = milliseconds_since_epoch
        @last_modified_timestamp = seconds_since_epoch
        @usn = NEW_OBJECT_USN
        %w[type queue due ivl factor reps lapses left odue odid flags].each do |instance_variable_name|
          instance_variable_set "@#{instance_variable_name}", 0
        end
        @data = "{}"
      end

      def setup_instance_variables_from_existing(card_data:)
        setup_collaborator_object_instance_variables_from_existing(card_data: card_data)
        setup_simple_instance_variables_from_existing(card_data: card_data)
      end

      def setup_collaborator_object_instance_variables_from_existing(card_data:)
        @collection = note.note_type.collection
        @deck = collection.find_deck_by id: card_data["did"]
        @card_template = note.note_type.card_templates.find do |card_template|
          card_template.ordinal_number == card_data["ord"]
        end
      end

      def setup_simple_instance_variables_from_existing(card_data:)
        @last_modified_timestamp = card_data["mod"]
        %w[id usn type queue due ivl factor reps lapses left odue odid flags data].each do |instance_variable_name|
          instance_variable_set "@#{instance_variable_name}", card_data[instance_variable_name]
        end
      end

    public

    def save(note_exists_already: false) # :nodoc:
      note_exists_already ? update_card_in_collection_anki21 : insert_new_card_in_collection_anki21
    end

    private

      def update_card_in_collection_anki21
        statement = @collection.anki_package.prepare <<~SQL
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
        statement = @collection.anki_package.prepare <<~SQL
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
