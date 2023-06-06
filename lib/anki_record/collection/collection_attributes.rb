# frozen_string_literal: true

module AnkiRecord
  ##
  # Module with the Collection class's attribute readers, writers, and accessors.
  module CollectionAttributes
    ##
    # The collection's id, which is also the id of the col record in the collection.anki21 database (usually 1).
    attr_reader :id

    ##
    # The number of milliseconds since the 1970 epoch when the collection record was created.
    attr_reader :created_at_timestamp

    ##
    # The number of milliseconds since the 1970 epoch at which the collection record was last modified.
    attr_reader :last_modified_timestamp
  end
end
