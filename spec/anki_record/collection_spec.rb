# frozen_string_literal: true

RSpec.describe AnkiRecord::Collection do
  subject(:collection) { AnkiRecord::Collection.new }
  describe "::new" do
    it "instantiates a new Collection object" do
      expect(collection.instance_of?(AnkiRecord::Collection)).to eq true
    end
  end
end
