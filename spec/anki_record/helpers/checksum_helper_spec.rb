# frozen_string_literal: true

class MockChecksumHelperClass
  include AnkiRecord::Helpers::ChecksumHelper
end

RSpec.describe AnkiRecord::Helpers::ChecksumHelper do
  subject(:mock_helper) { MockChecksumHelperClass.new }

  describe "#checksum" do
    it "computes the first 10 characters of the sha1 hash of the word cat" do
      expect(mock_helper.checksum("cat")).to eq "2644024973"
    end

    it "computes the first 10 characters of the sha1 hash of the word forest" do
      expect(mock_helper.checksum("forest")).to eq "198023927"
    end

    it "computes the first 10 characters of the sha1 hash of the sentence" do
      expect(mock_helper.checksum("How many calories are in one gram of alcohol?")).to eq "306960154"
    end
  end
end
