# frozen_string_literal: true

# rubocop:disable RSpec/ContextWording
RSpec.shared_context "collection shared helpers" do
  subject(:collection) { described_class.new(anki_package: anki_package) }

  let(:anki_package) { AnkiRecord::AnkiPackage.new(name: "package_to_test_collection") }

  after { cleanup_test_files(directory: ".") }
end
# rubocop:enable RSpec/ContextWording
