# frozen_string_literal: true

require "pry"

require_relative "helpers/shared_constants_helper"
require_relative "helpers/time_helper"

module AnkiRecord
  ##
  # Deck represents an Anki deck
  class Deck
    include SharedConstantsHelper
    include TimeHelper

    DEFAULT_DECK_TODAY_ARRAY = [0, 0].freeze
    DEFAULT_COLLAPSED = false

    attr_accessor :name, :description

    attr_reader :collection, :id, :last_modified_time, :deck_options_group_id

    # TODO: All instance variables should at least be readable

    private_constant :DEFAULT_DECK_TODAY_ARRAY, :DEFAULT_COLLAPSED

    ##
    # Instantiate a new Deck
    def initialize(collection:, name: nil, args: nil)
      raise ArgumentError unless (name && args.nil?) || (args && args["name"])

      @collection = collection
      if args
        setup_deck_instance_variables_from_existing(args: args)
      else
        setup_deck_instance_variables(name: name)
      end
    end

    ##
    # Instantiates a Deck from an existing JSON object from the Anki col.decks column
    def self.from_existing(collection:, deck_hash:)
      new(collection: collection, args: deck_hash)
    end

    private

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def setup_deck_instance_variables_from_existing(args:)
        @id = args["id"]
        @last_modified_time = args["mod"]
        @name = args["name"]
        @usn = args["usn"]
        @learn_today = args["lrnToday"]
        @review_today = args["revToday"]
        @new_today = args["newToday"]
        @time_today = args["timeToday"]
        @collapsed_in_main_window = args["collapsed"]
        @collapsed_in_browser = args["browserCollapsed"]
        @description = args["desc"]
        @dyn = args["dyn"]
        @deck_options_group_id = args["conf"]
        @extend_new = args["extendNew"]
        @extend_review = args["extendRev"]
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      # rubocop:disable Metrics/MethodLength
      def setup_deck_instance_variables(name:)
        @id = milliseconds_since_epoch
        @last_modified_time = seconds_since_epoch
        @name = name
        @usn = NEW_OBJECT_USN
        @learn_today = @review_today = @new_today = @time_today = DEFAULT_DECK_TODAY_ARRAY
        @collapsed_in_main_window = DEFAULT_COLLAPSED
        @collapsed_in_browser = DEFAULT_COLLAPSED
        @description = ""
        @dyn = NON_FILTERED_DECK_DYN
        @deck_options_group_id = nil # TODO
        @extend_new = 0
        @extend_review = 0
      end
    # rubocop:enable Metrics/MethodLength
  end
end
