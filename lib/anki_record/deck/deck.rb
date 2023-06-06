# frozen_string_literal: true

require_relative "deck_attributes"
require_relative "deck_defaults"
require_relative "../helpers/shared_constants_helper"
require_relative "../helpers/time_helper"

module AnkiRecord
  ##
  # Deck represents an Anki deck.
  class Deck
    include DeckAttributes
    include DeckDefaults
    include Helpers::SharedConstantsHelper
    include Helpers::TimeHelper

    ##
    # Instantiates a new Deck object belonging to +anki21_database+ with name +name+.
    def initialize(anki21_database:, name: nil, args: nil)
      raise ArgumentError unless (name && args.nil?) || (args && args["name"])

      @anki21_database = anki21_database
      if args
        setup_deck_instance_variables_from_existing(args:)
      else
        setup_deck_instance_variables(name:)
      end

      @anki21_database.add_deck self
      save if args
    end

    ##
    # Saves the deck to the collection.anki21 database.
    def save
      collection_decks_hash = anki21_database.decks_json
      collection_decks_hash[@id] = to_h
      sql = "update col set decks = ? where id = ?"
      anki21_database.prepare(sql).execute([JSON.generate(collection_decks_hash), anki21_database.collection.id])
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

    # :nodoc:
    # :nocov:
    def inspect
      "#<AnkiRecord::Deck:#{object_id} id: #{id} name: #{name} description: #{description}>"
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
        @deck_options_group = anki21_database.find_deck_options_group_by(id: args["conf"])
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
        @deck_options_group = anki21_database.find_deck_options_group_by id: default_deck_options_group_id
        @extend_new = 0
        @extend_review = 0
      end
    # rubocop:enable Metrics/MethodLength
  end
end
