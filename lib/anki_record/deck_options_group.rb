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
    # The name of the options group
    attr_accessor :name

    ##
    # One of many attributes that is currently read-only and needs to be documented.
    attr_reader :collection, :id, :last_modified_time, :usn, :max_taken, :auto_play, :timer, :replay_question,
                :new_options, :review_options, :lapse_options, :dyn, :new_mix, :new_per_day_minimum,
                :interday_learning_mix, :review_order, :new_sort_order, :new_gather_priority, :bury_interday_learning

    ##
    # Instantiates a new deck options group called +name+ with defaults
    def initialize(collection:, name: nil, args: nil)
      # TODO: extract this check to a shared helper
      raise ArgumentError unless (name && args.nil?) || (args && args["name"])

      @collection = collection

      if args
        setup_deck_options_group_instance_variables_from_existing(args: args)
      else
        setup_deck_options_group_instance_variables(name: name)
      end
    end

    private

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def setup_deck_options_group_instance_variables_from_existing(args:)
        @id = args["id"]
        @last_modified_time = args["mod"]
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
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

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
