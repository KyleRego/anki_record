# frozen_string_literal: true

module AnkiRecord
  ##
  # Helper module to hold the constants used by Collection
  module CollectionHelper
    DEFAULT_CONFIGURATION_HASH = {
      collapseTime: 1200,
      curDeck: 1,
      curModel: 1_674_448_040_667,
      creationOffset: 300,
      activeDecks: [1],
      nextPos: 1,
      estTimes: true,
      sortBackwards: false,
      schedVer: 2,
      sortType: "noteFld",
      timeLim: 0,
      dueCounts: true,
      newSpread: 0,
      dayLearnFirst: false,
      addToCur: true
    }.freeze

    private_constant :DEFAULT_CONFIGURATION_HASH
  end
end
