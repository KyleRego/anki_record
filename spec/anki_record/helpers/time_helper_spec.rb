# frozen_string_literal: true

class MockTimeHelperClass
  include AnkiRecord::Helpers::TimeHelper
end

RSpec.describe AnkiRecord::Helpers::TimeHelper do
  describe "#milliseconds_since_epoch" do
    it "returns approximately the integer number of milliseconds since the 1970 epoch" do
      seconds_since_epoch = Time.now.to_i
      expect(MockTimeHelperClass.new.milliseconds_since_epoch).to be_within(6000).of(seconds_since_epoch * 1000)
    end
  end

  describe "#seconds_since_epoch" do
    it "returns approximately the integer number of seconds since the 1970 epoch" do
      seconds_since_epoch = Time.now.to_i
      expect(MockTimeHelperClass.new.seconds_since_epoch).to be_within(5).of(seconds_since_epoch)
    end
  end
end
