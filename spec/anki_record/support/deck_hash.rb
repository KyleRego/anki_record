# frozen_string_literal: true

RSpec.shared_context "when the JSON of a deck from the col record is a Ruby hash" do
  let(:default_deck_hash) do
    { "id" => 1,
      "mod" => 0,
      "name" => "Default",
      "usn" => 0,
      "lrnToday" => [0, 0],
      "revToday" => [0, 0],
      "newToday" => [0, 0],
      "timeToday" => [0, 0],
      "collapsed" => true,
      "browserCollapsed" => true,
      "desc" => "",
      "dyn" => 0,
      "conf" => 1,
      "extendNew" => 0,
      "extendRev" => 0 }
  end
end
