# frozen_string_literal: true

require "date"

module AnkiRecord
  module Helpers
    ##
    # Helper module to calculate integer time values since the 1970 epoch.
    #
    # Specifically, the time that has passed since 00:00:00 UTC Jan 1 1970.
    module TimeHelper
      ##
      # Returns approximately the number of milliseconds since the 1970 epoch.
      # This is used for some of the primary key ids. To prevent violation of the
      # uniqueness constraint, sleep is called for 1 millisecond.
      def milliseconds_since_epoch
        sleep 0.001
        DateTime.now.strftime("%Q").to_i
      end

      ##
      # Returns approximately the number of seconds since the 1970 epoch.
      def seconds_since_epoch
        Time.now.to_i
      end
    end
  end
end
