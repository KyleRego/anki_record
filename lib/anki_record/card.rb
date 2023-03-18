# frozen_string_literal: true

require "pry"

require_relative "helpers/shared_constants_helper"
require_relative "helpers/time_helper"

module AnkiRecord
  ##
  # Card represents an Anki card.
  class Card
    include TimeHelper
    include SharedConstantsHelper

    ##
    # The note object that the card belongs to
    attr_reader :note

    ##
    # The deck object that the card belongs to
    attr_reader :deck

    ##
    # The collection object that the card belongs to
    attr_reader :collection

    ##
    # The card template object that the card uses as its template
    attr_reader :card_template

    ##
    # The id of the card.
    # This is approximately the number of milliseconds since the 1970 epoch when the card was created.
    attr_reader :id

    ##
    # The number of seconds since the 1970 epoch when the card was most recently modified.
    attr_reader :last_modified_time

    ##
    # The usn (update sequence number) of the card
    attr_reader :usn

    ##
    # TODO: Investigate all these
    attr_reader :type, :queue, :due, :ivl, :factor, :reps, :lapses, :left, :odue, :odid, :flags, :data

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def initialize(note:, card_template: nil, card_data: nil)
      if note && card_template && (note.note_type == card_template.note_type)
        setup_instance_variables(note: note, card_template: card_template)
      elsif note && card_data
        setup_instance_variables_from_existing(note: note, card_data: card_data)
      else
        raise ArgumentError
      end
    end

    def setup_instance_variables(note:, card_template:)
      @note = note
      @deck = @note.deck
      @collection = @deck.collection
      @card_template = card_template

      @id = milliseconds_since_epoch
      @last_modified_time = seconds_since_epoch
      @usn = NEW_OBJECT_USN
      @type = 0
      @queue = 0
      @due = 0
      @ivl = 0
      @factor = 0
      @reps = 0
      @lapses = 0
      @left = 0
      @odue = 0
      @odid = 0
      @flags = 0
      @data = "{}"
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    private

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def setup_instance_variables_from_existing(note:, card_data:)
        @note = note
        @collection = note.note_type.collection
        @deck = collection.find_deck_by id: card_data["did"]
        @id = card_data["id"]
        @ordinal_number = card_data["ord"]
        @last_modified_time = card_data["mod"]
        @usn = card_data["usn"]
        @type = card_data["type"]
        @queue = card_data["queue"]
        @due = card_data["due"]
        @ivl = card_data["ivl"]
        @factor = card_data["factor"]
        @reps = card_data["reps"]
        @lapses = card_data["lapses"]
        @left = card_data["left"]
        @odue = card_data["odue"]
        @odid = card_data["odid"]
        @flags = card_data["flags"]
        @data = card_data["data"]
      end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    public

    # rubocop:disable Metrics/MethodLength
    def save(note_exists_already: false) # :nodoc:
      if note_exists_already
        statement = @collection.anki_package.prepare <<~SQL
          update cards set nid = ?, did = ?, ord = ?, mod = ?, usn = ?, type = ?,
                            queue = ?, due = ?, ivl = ?, factor = ?, reps = ?, lapses = ?,
                            left = ?, odue = ?, odid = ?, flags = ?, data = ? where id = ?
        SQL
        statement.execute [@note.id, @deck.id, ordinal_number,
                           @last_modified_time, @usn, @type, @queue,
                           @due, @ivl, @factor, @reps,
                           @lapses, @left, @odue, @odid, @flags, @data, @id]
      else
        statement = @collection.anki_package.prepare <<~SQL
          insert into cards (id, nid, did, ord,
                            mod, usn, type, queue,
                            due, ivl, factor, reps,
                            lapses, left, odue, odid, flags, data)
                      values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        SQL
        statement.execute [@id, @note.id, @deck.id, ordinal_number,
                           @last_modified_time, @usn, @type, @queue,
                           @due, @ivl, @factor, @reps,
                           @lapses, @left, @odue, @odid, @flags, @data]
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

      def ordinal_number
        @card_template&.ordinal_number || @ordinal_number
      end
  end
end
