# frozen_string_literal: true

RSpec.shared_context "when the anki package is a clean slate" do
  let(:anki_package) do
    AnkiRecord::AnkiPackage.new(name: "clean_slate")
  end

  let(:anki21_database) do
    anki_package.anki21_database
  end

  let(:collection) do
    anki21_database.collection
  end
end
