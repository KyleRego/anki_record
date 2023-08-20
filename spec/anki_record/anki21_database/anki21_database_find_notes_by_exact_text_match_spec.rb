# frozen_string_literal: true

require "./spec/anki_record/support/clean_slate_anki_package"

RSpec.describe AnkiRecord::Anki21Database, "#find_notes_by_exact_text_match" do
  subject(:find_notes_by_exact_text_match) do
    anki21_database.find_notes_by_exact_text_match(text:)
  end

  include_context "when the anki package is a clean slate"

  context "when there are 5 basic notes in the database" do
    before do
      default_deck = anki21_database.find_deck_by(name: "Default")
      basic_note_type = anki21_database.find_note_type_by(name: "Basic")
      5.times do |i|
        note = AnkiRecord::Note.new(deck: default_deck, note_type: basic_note_type)
        note.front = "Note #{i} front"
        note.back = "Note #{i} back"
        note.save
      end
    end

    context "when text arg is an empty string" do
      let(:text) { "" }

      it "returns an empty array" do
        expect(find_notes_by_exact_text_match).to be_empty
      end
    end

    context "when text arg matches all 5 notes" do
      let(:text) { "Note" }

      it "returns an array of all 5 basic notes" do
        expect(find_notes_by_exact_text_match.count).to eq 5
        expect(find_notes_by_exact_text_match.last).to be_a AnkiRecord::Note
        expect(find_notes_by_exact_text_match.map(&:front).uniq.count).to eq 5
      end
    end

    context "when text arg matches just one note's front" do
      let(:text) { "Note 0 front" }

      it "returns an array with just that note" do
        expect(find_notes_by_exact_text_match.count).to eq 1
        expect(find_notes_by_exact_text_match.first).to be_a AnkiRecord::Note
        expect(find_notes_by_exact_text_match.first.front).to eq text
      end
    end

    context "when text arg matches just one note's back" do
      let(:text) { "Note 0 back" }

      it "returns an array with just that note" do
        expect(find_notes_by_exact_text_match.count).to eq 1
        expect(find_notes_by_exact_text_match.first).to be_a AnkiRecord::Note
        expect(find_notes_by_exact_text_match.first.back).to eq text
      end
    end
  end
end
