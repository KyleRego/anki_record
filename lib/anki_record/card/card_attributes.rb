# frozen_string_literal: true

module AnkiRecord
  module CardAttributes # :nodoc:
    attr_reader :anki21_database, :note, :deck, :card_template, :id, :last_modified_timestamp, :usn, :type, :queue,
                :due, :ivl, :factor, :reps, :lapses, :left, :odue, :odid, :flags, :data
  end
end
