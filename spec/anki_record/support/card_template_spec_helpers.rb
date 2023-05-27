# frozen_string_literal: true

# rubocop:disable RSpec/ContextWording
RSpec.shared_context "card template helpers" do
  after { cleanup_test_files(directory: ".") }

  let(:collection_argument) do
    AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection").collection
  end
  let(:note_type_argument) { AnkiRecord::NoteType.new(collection: collection_argument, name: "test note type for templates") }

  let(:card_template_hash) do
    { "name" => "Card 1",
      "ord" => 0,
      "qfmt" => "{{Front}}",
      "afmt" => "{{FrontSide}}\n\n<hr id=answer>\n\n{{Back}}",
      "bqfmt" => "",
      "bafmt" => "",
      "did" => nil,
      "bfont" => "",
      "bsize" => 0 }
  end
end
# rubocop:enable RSpec/ContextWording
