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
    # The card template object that the card uses as its template
    attr_reader :card_template

    ##
    # The id of the card. This is approximately the number of milliseconds since the 1970 epoch when the card was created.
    attr_reader :id

    ##
    # The number of seconds since the 1970 epoch when the card was most recently modified.
    attr_reader :last_modified_time

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def initialize(note:, card_template:)
      raise ArgumentError unless note && card_template && note.note_type == card_template.note_type

      @note = note
      @anki_package = @note.deck.collection.anki_package

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
      @anki_package.execute <<~SQL
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
