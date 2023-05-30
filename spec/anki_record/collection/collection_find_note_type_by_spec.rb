# frozen_string_literal: true

require "./spec/anki_record/support/clean_slate_anki_package"

RSpec.describe AnkiRecord::Collection, "#find_note_type_by" do
  include_context "when the anki package is a clean slate"

  it "throws an ArgumentError when passed both name and id arguments" do
    expect { collection.find_note_type_by(name: "name", id: "id") }.to raise_error ArgumentError
  end

  it "throws an ArgumentError when passed neither a name nor an id argument" do
    expect { collection.find_note_type_by }.to raise_error ArgumentError
  end

  it "returns nil when passed a name that there is no note type with that name" do
    expect(collection.find_note_type_by(name: "no-note-type-with-this-name")).to be_nil
  end

  it "returns the note type when passed a name where there is a note type with that name" do
    expect(collection.find_note_type_by(name: "Basic").instance_of?(AnkiRecord::NoteType)).to be true
    expect(collection.find_note_type_by(name: "Basic").name).to eq "Basic"
  end

  it "returns nil when passed an id where there is no note type with that id" do
    expect(collection.find_note_type_by(id: "1234")).to be_nil
  end

  it "returns the note type when passed an id where there is a note type with that id" do
    basic_note_type_id = JSON.parse(collection.anki21_database.prepare("select * from col;").first[9]).keys.first.to_i
    expect(collection.find_note_type_by(id: basic_note_type_id).instance_of?(AnkiRecord::NoteType)).to be true
    expect(collection.find_note_type_by(id: basic_note_type_id).id).to eq basic_note_type_id
  end
end
