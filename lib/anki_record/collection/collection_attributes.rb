# frozen_string_literal: true

module AnkiRecord
  ##
  # Module with the Collection class's attribute readers, writers, and accessors.
  module CollectionAttributes
    ##
    # The id of the col record in the collection.anki21 database which is usually 1.
    attr_reader :id

    ##
    # Creation timestamp of the col record in milliseconds since the 1970 epoch.
    attr_reader :created_at_timestamp

    ##
    # Last modified at timestamp of the col record in milliseconds since the 1970 epoch.
    attr_reader :last_modified_timestamp
  end
end
