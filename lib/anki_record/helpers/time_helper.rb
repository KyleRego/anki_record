# frozen_string_literal: true

require "date"

module AnkiRecord
  ##
  # Helper module to calculate integer time values since the 1970 epoch
  #
  # Specifically, the time that has passed since 00:00:00 UTC Jan 1 1970
  module TimeHelper
    ##
    # Return the number of milliseconds since the 1970 epoch
    def milliseconds_since_epoch
      DateTime.now.strftime("%Q").to_i
    end

    ##
    # Return the number of seconds since the 1970 epoch
    def seconds_since_epoch
      Time.now.to_i
    end
  end
end
