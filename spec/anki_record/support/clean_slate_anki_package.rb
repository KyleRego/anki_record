# frozen_string_literal: true

RSpec.shared_context "when the anki package is a clean slate" do
  let(:clean_slate_anki_package_name) { "clean_slate_anki_package" }

  let(:anki_package) { AnkiRecord::AnkiPackage.new(name: clean_slate_anki_package_name) }

  let(:anki21_database) { anki_package.anki21_database }

  let(:collection) { anki21_database.collection }

  after { cleanup_test_files(directory: ".") }

  let(:tmpdir) { anki_package.tmpdir }
end
