# frozen_string_literal: true

class MockChecksumHelperClass
  include AnkiRecord::ChecksumHelper
end

RSpec.describe AnkiRecord::ChecksumHelper do
  subject { MockChecksumHelperClass.new }
  describe "#checksum" do
    it "should compute the first 10 characters of the sha1 hash of the argument" do
      expect(subject.checksum("cat")).to eq "2644024973"
    end
    it "should compute the first 10 characters of the sha1 hash of the argument" do
      expect(subject.checksum("forest")).to eq "198023927"
    end
    it "should compute the first 10 characters of the sha1 hash of the argument" do
      expect(subject.checksum("How many calories are in one gram of alcohol?")).to eq "306960154"
    end
  end
end
