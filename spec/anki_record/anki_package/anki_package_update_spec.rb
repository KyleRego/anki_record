# frozen_string_literal: true

RSpec.describe AnkiRecord::AnkiPackage, ".update" do
  let(:create_anki_package) do
    if defined?(closure_argument)
      described_class.update(path:, &closure_argument)
    else
      described_class.update(path:)
    end
  end

  context "when path is not to a file" do
    let(:path) { "not_a_path_to_anything" }

    it "raises an error" do
      expect { create_anki_package }.to raise_error RuntimeError
    end
  end

  context "when path is to a file but it does not have the .apkg extension" do
    let(:path) { "test.txt" }

    before { File.new("test.txt", "w") }
    after { File.delete("test.txt") }

    it "raises an error" do
      expect { create_anki_package }.to raise_error RuntimeError
    end
  end

  context "when path is to an Anki package file" do
    let(:existing_anki_package_name) { "test_package.apkg" }
    let(:existing_deck_name) { "test_deck" }
    let(:path) { "./#{existing_anki_package_name}" }

    before do
      described_class.create(name: existing_anki_package_name) do |anki21_database|
        custom_deck = AnkiRecord::Deck.new(anki21_database:, name: existing_deck_name)
        custom_deck.save

        basic_note_type = anki21_database.find_note_type_by name: "Basic"

        10.times do |i|
          note = AnkiRecord::Note.new(note_type: basic_note_type, deck: custom_deck)
          note.front = "Front of basic note #{i}"
          note.back = "Back of basic note"
          note.save
        end

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

    # rubocop:disable RSpec/ExampleLength
    it "yields an Anki21Database to the block with the existing Anki package data" do
      described_class.update(path:) do |anki21_database|
        expect(anki21_database).to be_a AnkiRecord::Anki21Database
        deck = anki21_database.find_deck_by(name: existing_deck_name)
        expect(deck.name).to eq("test_deck")
        expect(anki21_database.prepare("select count(*) from notes;").execute.first["count(*)"]).to eq(20)
      end
    end
    # rubocop:enable RSpec/ExampleLength

    it "returns an AnkiPackage when not passed a block" do
      expect(create_anki_package).to be_a(described_class)
    end

    context "when passed a block that throws an exception" do
      let(:closure_argument) { proc { raise "runtime error" } }

      it "leaves the original Anki package" do
        expect { create_anki_package }.to output.to_stdout
        expect(File.exist?("./#{existing_anki_package_name}")).to be true
      end
    end

    context "when an error occurs during zipping and replacing the original Anki package" do
      let(:closure_argument) { {} }

      it "leaves the original Anki package" do
        allow(FileUtils).to receive(:rm).and_raise
        expect { create_anki_package }.to output.to_stdout
        expect(File.exist?("./#{existing_anki_package_name}")).to be true
      end
    end
  end
end
