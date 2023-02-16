# frozen_string_literal: true

RSpec.describe AnkiRecord::NoteType do
  let(:name_argument) { "test note type" }
  subject(:note_type) { AnkiRecord::NoteType.new name: name_argument }

  describe "::new" do
    context "with valid arguments" do
      it "instantiates a note type with a name" do
        expect(note_type.name).to eq name_argument
      end
      it "instantiates a note type with an integer id using #milliseconds_since_epoch" do
        expect(note_type.id.class).to eq Integer
      end
    end
    context "without a name argument" do
      let(:name_argument) { nil }
      it "throws an ArgumentError" do
        expect { subject }.to raise_error ArgumentError
      end
    end
  end
end
