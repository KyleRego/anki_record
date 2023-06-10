# frozen_string_literal: true

RSpec.describe AnkiRecord::Helpers::AnkiGuidHelper do
  describe ".globally_unique_id" do
    it "computes a 10 character string" do
      result = described_class.globally_unique_id
      expect(result).to be_a String
      expect(result.length).to eq 10
    end
  end
end
