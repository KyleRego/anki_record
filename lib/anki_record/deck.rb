# frozen_string_literal: true

require "pry"

require_relative "helpers/shared_constants_helper"
require_relative "helpers/time_helper"

module AnkiRecord
  ##
  # Deck represents an Anki deck.
  # In the collection.anki21 database, the deck is a JSON object
  # which is part of a larger JSON object: the value of the col record's decks column.
  class Deck
    include SharedConstantsHelper
    include TimeHelper

    ##
    # The deck's collection object.
    attr_reader :collection

    ##
    # The deck's name.
    attr_accessor :name

    ##
    # The deck's description.
    attr_accessor :description

    ##
    # The deck's id.
    attr_reader :id

    ##
    # The number of seconds since the 1970 epoch when the deck was last modified.
    attr_reader :last_modified_timestamp

    ##
    # The deck's deck options group object.
    attr_reader :deck_options_group

    ##
    # Instantiates a new Deck object belonging to +collection+ with name +name+.
    def initialize(collection:, name: nil, args: nil)
      raise ArgumentError unless (name && args.nil?) || (args && args["name"])

      @collection = collection
      if args
        setup_deck_instance_variables_from_existing(args: args)
      else
        setup_deck_instance_variables(name: name)
      end

      @collection.add_deck self
      save
    end

    ##
    # Saves the deck (or updates it) in the collection.anki21 database.
    def save
      collection_decks_hash = collection.decks_json
      collection_decks_hash[@id] = to_h
      sql = "update col set decks = ? where id = ?"
      collection.anki_package.prepare(sql).execute([JSON.generate(collection_decks_hash), collection.id])
    end

    def to_h # :nodoc:
      {
        id: @id, mod: @last_modified_timestamp, name: @name, usn: @usn,
        lrnToday: @learn_today, revToday: @review_today, newToday: @new_today, timeToday: @time_today,
        collapsed: @collapsed_in_main_window, browserCollapsed: @collapsed_in_browser,
        desc: @description, dyn: @dyn, conf: @deck_options_group.id,
        extendNew: @extend_new, extendRev: @extend_review
      }
    end

    private

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def setup_deck_instance_variables_from_existing(args:)
        @id = args["id"]
        @last_modified_timestamp = args["mod"]
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
        @deck_options_group = @collection.find_deck_options_group_by id: args["conf"]
        @extend_new = args["extendNew"]
        @extend_review = args["extendRev"]
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      # rubocop:disable Metrics/MethodLength
      def setup_deck_instance_variables(name:)
        @id = milliseconds_since_epoch
        @last_modified_timestamp = seconds_since_epoch
        @name = name
        @usn = NEW_OBJECT_USN
        @learn_today = @review_today = @new_today = @time_today = default_deck_today_array
        @collapsed_in_main_window = default_collapsed
        @collapsed_in_browser = default_collapsed
        @description = ""
        @dyn = NON_FILTERED_DECK_DYN
        @deck_options_group = @collection.find_deck_options_group_by id: default_deck_options_group_id
        @extend_new = 0
        @extend_review = 0
      end
      # rubocop:enable Metrics/MethodLength

      def default_deck_options_group_id
        collection.deck_options_groups.min_by(&:id).id
      end

      def default_deck_today_array
        [0, 0].freeze
      end

      def default_collapsed
        false
      end
  end
end
