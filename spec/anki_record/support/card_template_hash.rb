# frozen_string_literal: true

RSpec.shared_context "when the JSON of a card template from the col record is a Ruby hash" do
  let(:basic_note_first_card_template_hash) do
    { "name" => "Card 1",
      "ord" => 0,
      "qfmt" => "{{Front}}",
      "afmt" => "{{FrontSide}}\n\n<hr id=answer>\n\n{{Back}}",
      "bqfmt" => "",
      "bafmt" => "",
      "did" => nil,
      "bfont" => "",
      "bsize" => 0 }
  end
end
