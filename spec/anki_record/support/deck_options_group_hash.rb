# frozen_string_literal: true

RSpec.shared_context "when the JSON of a deck options group from the col record is a Ruby hash" do
  let(:default_deck_options_group_hash) do
    { "id" => 1,
      "mod" => 0,
      "name" => "Default",
      "usn" => 0,
      "maxTaken" => 60,
      "autoplay" => true,
      "timer" => 0,
      "replayq" => true,
      "new" => { "bury" => false, "delays" => [1.0, 10.0], "initialFactor" => 2500, "ints" => [1, 4, 0], "order" => 1, "perDay" => 20 },
      "rev" => { "bury" => false, "ease4" => 1.3, "ivlFct" => 1.0, "maxIvl" => 36_500, "perDay" => 200, "hardFactor" => 1.2 },
      "lapse" => { "delays" => [10.0], "leechAction" => 1, "leechFails" => 8, "minInt" => 1, "mult" => 0.0 },
      "dyn" => false,
      "newMix" => 0,
      "newPerDayMinimum" => 0,
      "interdayLearningMix" => 0,
      "reviewOrder" => 0,
      "newSortOrder" => 0,
      "newGatherPriority" => 0,
      "buryInterdayLearning" => false }
  end
end
