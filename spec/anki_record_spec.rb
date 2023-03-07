# frozen_string_literal: true

RSpec.describe AnkiRecord do
  it "is being developed" do
    expect(true).to eq true
  end

  before(:all) { cleanup_test_files directory: "." }

  describe "an unfinished end to end test" do
    it "is an example" do
      AnkiRecord::AnkiPackage.new(name: "test") do |apkg|
        collection = apkg.collection

        crazy_note_type = AnkiRecord::NoteType.new collection: collection, name: "crazy note type"

        AnkiRecord::NoteField.new note_type: crazy_note_type, name: "crazy front"
        AnkiRecord::NoteField.new note_type: crazy_note_type, name: "crazy back"

        crazy_card_template = AnkiRecord::CardTemplate.new note_type: crazy_note_type, name: "crazy card 1"
        crazy_card_template.question_format = "{{crazy front}}"
        crazy_card_template.answer_format = "{{crazy back}}"

        # crazy_note_type.save # TODO

        crazy_deck = AnkiRecord::Deck.new collection: collection, name: "crazy deck"
        expect(crazy_deck.name).to eq "crazy deck"

        # crazy_deck.save # TODO
      end
    end
  end
end
