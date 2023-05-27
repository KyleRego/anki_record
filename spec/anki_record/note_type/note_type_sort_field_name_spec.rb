# frozen_string_literal: true

require_relative "../support/note_type_spec_helpers"

RSpec.describe AnkiRecord::NoteType, "#sort_field_name" do
  subject(:basic_note_type_from_existing) { described_class.new(collection: collection_argument, args: basic_model_hash) }

  include_context "note type helpers"

  let(:name_argument) { "test note type" }
  let(:collection_argument) do
    AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection").collection
  end

  context "when it is the default Basic note type" do
    it "returns the name of the field used to sort, 'Front'" do
      expect(basic_note_type_from_existing.sort_field_name).to eq "Front"
    end
  end
end
