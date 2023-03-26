# frozen_string_literal: true

require "date"

module AnkiRecord
  ##
  # Helper module to calculate integer time values since the 1970 epoch.
  #
  # Specifically, the time that has passed since 00:00:00 UTC Jan 1 1970.
  module TimeHelper
    ##
    # Returns approximately the number of milliseconds since the 1970 epoch.
    # A random amount of milliseconds between -5000 and 5000 is added so that
    # primary key ids calculated with this should be unique.
    def milliseconds_since_epoch
      DateTime.now.strftime("%Q").to_i + rand(-5000..5000)
    end

    ##
    # Returns approximately the number of seconds since the 1970 epoch.
    def seconds_since_epoch
      Time.now.to_i
    end
  end
end
