# frozen_string_literal: true

require_relative "../helpers/shared_constants_helper"
require_relative "../helpers/time_helper"
require_relative "deck_options_group_attributes"

module AnkiRecord
  ##
  # DeckOptionsGroup represents a set of options that can be applied to an Anki deck.
  # The interface to this has not been explored much so using the gem with these directly
  # may involve breaking encapsulation.
  class DeckOptionsGroup
    include DeckOptionsGroupAttributes
    include Helpers::SharedConstantsHelper
    include Helpers::TimeHelper

    ##
    # Instantiates a new deck options group belonging to +anki21_database+ with name +name+.
    def initialize(anki21_database:, name: nil, args: nil)
      raise ArgumentError unless (name && args.nil?) || (args && args["name"])

      @anki21_database = anki21_database

      if args
        setup_deck_options_group_instance_variables_from_existing(args:)
      else
        setup_deck_options_group_instance_variables(name:)
      end

      @anki21_database.add_deck_options_group self
    end

    private

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def setup_deck_options_group_instance_variables_from_existing(args:)
        @id = args["id"]
        @last_modified_timestamp = args["mod"]
        @name = args["name"]
        @usn = args["usn"]
        @max_taken = args["maxTaken"]
        @auto_play = args["autoplay"]
        @timer = args["timer"]
        @replay_question = args["true"]
        @new_options = args["new"]
        @review_options = args["rev"]
        @lapse_options = args["lapse"]
        @dyn = args["dyn"]
        @new_mix = args["newMix"]
        @new_per_day_minimum = args["newPerDayMinimum"]
        @interday_learning_mix = args["interdayLearningMix"]
        @review_order = args["reviewOrder"]
        @new_sort_order = args["new_sort_order"]
        @new_gather_priority = args["newGatherPriority"]
        @bury_interday_learning = args["buryInterdayLearning"]
      end

      def setup_deck_options_group_instance_variables(name:)
        @id = milliseconds_since_epoch
        @last_modified_timestamp = seconds_since_epoch
        @name = name
        @usn = NEW_OBJECT_USN
        @max_taken = 60
        @auto_play = true
        @timer = 0
        @replay_question = true
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
