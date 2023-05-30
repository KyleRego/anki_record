# frozen_string_literal: true

# TODO: Refactor so this module does not exist.
class MockDataQueryHelperClass
  include AnkiRecord::Helpers::DataQueryHelper
end

RSpec.describe AnkiRecord::Helpers::DataQueryHelper
