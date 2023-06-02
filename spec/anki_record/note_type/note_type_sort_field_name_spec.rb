# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"
require_relative "../support/note_type_hashes"

RSpec.describe AnkiRecord::NoteType, "#sort_field_name" do
  subject(:basic_note_type_from_hash) { described_class.new(collection:, args: basic_model_hash) }

  include_context "when the anki package is a clean slate"

  context "when it is the default Basic note type" do
    include_context "when the JSON of a note type from the col record is a Ruby hash"
    it "returns the name of the field used to sort, 'Front'" do
      expect(basic_note_type_from_hash.sort_field_name).to eq "Front"
    end
  end
end
