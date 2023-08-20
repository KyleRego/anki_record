# frozen_string_literal: true

require "./spec/anki_record/support/clean_slate_anki_package"

RSpec.describe AnkiRecord::Anki21Database, "#find_note_by" do
  subject(:find_note_by) do
    anki21_database.find_note_by(id: note_id, sfld: note_sfld)
  end

  include_context "when the anki package is a clean slate"

  let!(:note) do
    default_deck = anki21_database.find_deck_by(name: "Default")
    basic_note_type = anki21_database.find_note_type_by(name: "Basic")
    note = AnkiRecord::Note.new(deck: default_deck, note_type: basic_note_type)
    note.front = "This is the sort field by default"
    note.save
    note
  end

  let(:card) do
    note.cards.first
  end

  context "when both id and sfld args are nil" do
    let(:note_id) { nil }
    let(:note_sfld) { nil }

    it "raises an ArgumentError" do
      expect { find_note_by }.to raise_error(ArgumentError)
    end
  end

  context "when both id and sfld args are not nil" do
    let(:note_id) { note.id }
    let(:note_sfld) { "hello world" }

    it "raises an ArgumentError" do
      expect { find_note_by }.to raise_error(ArgumentError)
    end
  end

  context "when the parameter to find by is id" do
    let(:note_sfld) { nil }

    context "when there is no note for the given id" do
      let(:note_id) { "1234" }

      it "returns nil" do
        expect(find_note_by).to be_nil
      end
    end

    context "when there is a note for the given id passed as an integer" do
      let(:note_id) { note.id.to_i }

      it "returns the note" do
        found_note = find_note_by
        expect(found_note).to be_a AnkiRecord::Note
        expect(found_note.id).to eq note.id
        expect(found_note.cards.count).to eq 1
        expect(found_note.cards.first.id).to eq card.id
      end
    end

    context "when there is a note for the given id passed as a string" do
      let(:note_id) { note.id.to_s }

      it "returns the note" do
        found_note = find_note_by
        expect(found_note).to be_a AnkiRecord::Note
        expect(found_note.id).to eq note.id
        expect(found_note.cards.count).to eq 1
        expect(found_note.cards.first.id).to eq card.id
      end
    end
  end

  context "when the parameter to find by is sfld" do
    let(:note_id) { nil }

    context "when the sfld is not any note's sfld value" do
      let(:note_sfld) { "1238438" }

      it "returns nil" do
        expect(find_note_by).to be_nil
      end
    end

    context "when the sfld is the same as the note's sfld value" do
      let(:note_sfld) { note.sort_field_value }

      it "returns the note" do
        found_note = find_note_by
        expect(found_note).to be_a AnkiRecord::Note
        expect(found_note.id).to eq note.id
        expect(found_note.cards.count).to eq 1
        expect(found_note.cards.first.id).to eq card.id
      end
    end
  end
end
