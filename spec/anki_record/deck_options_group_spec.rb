# frozen_string_literal: true

RSpec.describe AnkiRecord::DeckOptionsGroup do
  subject(:deck_options_group) { AnkiRecord::DeckOptionsGroup.new(name: name_argument) }
  let(:name_argument) { "Test deck options group" }

  describe "::new" do
    context "without a name argument" do
      let(:name_argument) { nil }
      it "raises an ArgumentError" do
        expect { deck_options_group }.to raise_error ArgumentError
      end
    end
    context "with a name argument" do
      it "instantiates a new deck options group" do
        expect(deck_options_group.instance_of?(AnkiRecord::DeckOptionsGroup)).to eq true
      end
    end
  end
end
