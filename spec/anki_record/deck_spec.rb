# frozen_string_literal: true

RSpec.describe AnkiRecord::Deck do
  subject(:deck) { AnkiRecord::Deck.new(name: deck_name_argument) }
  let(:deck_name_argument) { "test deck name" }

  describe "::new" do
    it "instantiates a new Deck object" do
      expect(deck.instance_of?(AnkiRecord::Deck)).to eq true
    end
  end
end
