# frozen_string_literal: true

class MockTimeHelperClass
  include AnkiRecord::TimeHelper
end

RSpec.describe AnkiRecord::TimeHelper do
  describe "#milliseconds_since_epoch" do
    it "returns approximately the integer number of milliseconds since the 1970 epoch" do
      seconds_since_epoch = Time.now.to_i
      low = seconds_since_epoch * 999
      high = seconds_since_epoch * 1001
      expect(MockTimeHelperClass.new.milliseconds_since_epoch.between?(low, high)).to eq true
    end
  end
end
