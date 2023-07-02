# frozen_string_literal: true

RSpec.describe AnkiRecord::AnkiPackage, ".update" do
  it "raises an error when path is not to a file" do
    expect { described_class.update(path: "invalid_path") }.to raise_error RuntimeError
  end

  it "raises an error when path is to a file without the .apkg extension"

  context "when path is to an Anki package file" do
    let(:existing_anki_package_name) { "test_package.apkg" }
    let(:existing_deck_name) { "test_deck" }

    before do
      described_class.create(name: existing_anki_package_name) do |anki21_database|
        custom_deck = AnkiRecord::Deck.new(anki21_database:, name: existing_deck_name)
        custom_deck.save
        cloze_note_type = anki21_database.find_note_type_by(name: "Cloze")
        10.times do |i|
          note = AnkiRecord::Note.new(note_type: cloze_note_type, deck: custom_deck)
          note.text = "Cloze {{c1::Hello}} #{i}"
          note.back_extra = "World"
          note.save
        end
      end
    end

    after { cleanup_test_files(directory: ".") }

    it "yields an Anki21Database to the block that has the existing Anki package data" do
      pending "more implementation"
      described_class.update(path: "./#{existing_anki_package_name}") do |anki21_database|
        anki21_database.find_deck_by(name: existing_deck_name)
      end
    end
  end
end
