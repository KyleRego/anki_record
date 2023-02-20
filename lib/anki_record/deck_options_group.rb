# frozen_string_literal: true

require "pry"

require_relative "helpers/shared_constants_helper"
require_relative "helpers/time_helper"

module AnkiRecord
  ##
  # Represents the set of options that can be applied to a deck
  class DeckOptionsGroup
    include SharedConstantsHelper
    include TimeHelper

    ##
    # Instantiates a new deck options group with defaults
    def initialize(name:)
      # TODO: Extract common string validation to a helper?
      raise ArgumentError unless name

      setup_deck_options_group_instance_variables(name: name)
    end

    ##
    # TODO: Instantiates a note type from an existing json object in the col.dconf column
    def self.from_existing(dconf_hash:)
      dconf_hash["name"]
    end

    private

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def setup_deck_options_group_instance_variables(name:)
        @id = milliseconds_since_epoch
        @last_modified_time = seconds_since_epoch
        @name = name
        @usn = NEW_OBJECT_USN
        @max_taken = 60
        @auto_play = true
        @timer = 0
        @replay_q = true
        @new_options = { bury: false, delays: [1.0, 10.0], initialFactor: 2500, ints: [1, 4, 0], order: 1, perDay: 20 }
        @review_options = { bury: false, ease4: 1.3, ivlFct: 1.0, maxIvl: 36_500, perDay: 200, hardFactor: 1.2 }
        @lapse_options = { delays: [10.0], leechAction: 1, leechFails: 8, minInt: 1, mult: 0.0 }
        @dyn = NON_FILTERED_DECK_DYN
        @new_mix = 0
        @new_per_day_minimum = 0
        @interday_learning_mix = 0
        @review_order = 0
        @new_sort_order = 0
        @new_gather_priority = 0
        @bury_interday_learning = false
      end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
