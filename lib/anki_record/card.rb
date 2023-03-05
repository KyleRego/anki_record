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
    # The note that the card belongs to
    attr_reader :note

    ##
    # The card template that the card uses
    attr_reader :card_template

    ##
    # The id of the card, which is time it was created as the number of milliseconds since the 1970 epoch
    attr_reader :id

    ##
    # The time that the card was last modified as the number of seconds since the 1970 epoch
    attr_reader :last_modified_time

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def initialize(note:, card_template:)
      raise ArgumentError unless note && card_template && note.note_type == card_template.note_type

      @note = note
      @apkg = @note.deck.collection.anki_package

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
      @data = {}
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    ##
    # Saves the card to the collection.anki21 database
    def save
      @apkg.execute <<~SQL
        insert into cards (id, nid, did, ord,
                          mod, usn, type, queue,
                          due, ivl, factor, reps,
                          lapses, left, odue, odid, flags, data)
                    values ('#{@id}', '#{@note.id}', '#{@note.deck.id}', '#{@card_template.ordinal_number}',
                           '#{@last_modified_time}', '#{@usn}', '#{@type}', '#{@queue}',
                           '#{@due}', '#{@ivl}', '#{@factor}', '#{@reps}',
                           '#{@lapses}', '#{@left}', '#{@odue}', '#{@odid}', '#{@flags}', '#{@data}')
      SQL
    end
  end
end
