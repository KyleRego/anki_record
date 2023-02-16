# frozen_string_literal: true

require "date"

module AnkiRecord
  ##
  # Helper module which has a method to return the number of milliseconds
  # since the 1970 epoch as an integer
  module TimeHelper
    def milliseconds_since_epoch
      DateTime.now.strftime("%Q").to_i
    end
  end
end
