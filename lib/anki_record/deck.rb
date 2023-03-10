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

    ##
    # The collection object that the deck belongs to
    attr_reader :collection

    ##
    # The name of the deck
    attr_accessor :name

    ##
    # The description of the deck
    attr_accessor :description

    ##
    # The id of the deck
    attr_reader :id

    ##
    # The last time the deck was modified in number of seconds since the epoch
    #
    # TODO: is this really supposed to be seconds? Should it be milliseconds?
    attr_reader :last_modified_time

    # TODO: Probably this should be an accessor for the deck options group object instead of the id?
    ##
    # The id of the eck options/settings group that is applied to the deck
    attr_reader :deck_options_group_id

    ##
    # Instantiates a new Deck object
    def initialize(collection:, name: nil, args: nil)
      raise ArgumentError unless (name && args.nil?) || (args && args["name"])

      @collection = collection
      if args
        setup_deck_instance_variables_from_existing(args: args)
      else
        setup_deck_instance_variables(name: name)
      end

      @collection.add_deck self
    end

    ##
    # Saves the deck to the collection.anki21 database
    def save
      # TODO: should accessing the decks data be a method of collection? and other similar methods, e.g. col_decks_hash
      collection_decks_hash = JSON.parse(collection.anki_package.execute("select decks from col;").first["decks"])
      collection_decks_hash[@id] = to_h
      collection.anki_package.execute <<~SQL
        update col set decks = '#{JSON.generate(collection_decks_hash)}' where id = '#{collection.id}'
      SQL
    end

    def to_h # :nodoc:
      {
        id: @id, mod: @last_modified_time, name: @name, usn: @usn,
        lrnToday: @learn_today, revToday: @review_today, newToday: @new_today, timeToday: @time_today,
        collapsed: @collapsed_in_main_window, browserCollapsed: @collapsed_in_browser,
        desc: @description, dyn: @dyn,
        conf: @deck_options_group_id,
        extendNew: @extend_new, extendRev: @extend_review
      }
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
        @learn_today = @review_today = @new_today = @time_today = default_deck_today_array
        @collapsed_in_main_window = default_collapsed
        @collapsed_in_browser = default_collapsed
        @description = ""
        @dyn = NON_FILTERED_DECK_DYN
        @deck_options_group_id = nil # TODO: Set id to the default deck options group?
        # TODO: alternatively, if this is nil when the deck is saved, it can be set to the default options group id
        @extend_new = 0
        @extend_review = 0
      end
      # rubocop:enable Metrics/MethodLength

      def default_deck_today_array
        [0, 0].freeze
      end

      def default_collapsed
        false
      end
  end
end
