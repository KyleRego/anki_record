# frozen_string_literal: true

RSpec.shared_context "card template helpers" do
  after { cleanup_test_files(directory: ".") }

  let(:collection_argument) do
    anki_package = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
    AnkiRecord::Collection.new(anki_package: anki_package)
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