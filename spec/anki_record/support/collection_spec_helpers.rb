# frozen_string_literal: true

# rubocop:disable RSpec/ContextWording
RSpec.shared_context "collection shared helpers" do
  subject(:collection) do
    AnkiRecord::AnkiPackage.new(name: "package_to_test_collection").anki21_database.collection
  end

  after { cleanup_test_files(directory: ".") }
end
# rubocop:enable RSpec/ContextWording
