# frozen_string_literal: true

# rubocop:disable RSpec/ContextWording
RSpec.shared_context "note type helpers" do
  after { cleanup_test_files(directory: ".") }

  # rubocop:disable Layout/LineContinuationLeadingSpace
  # rubocop:disable Metrics/MethodLength
  ##
  # Returns the Ruby hash representing the default Basic note type args
  def basic_model_hash
    { "id" => 1_676_902_364_661,
      "name" => "Basic",
      "type" => 0,
      "mod" => 0,
      "usn" => 0,
      "sortf" => 0,
      "did" => nil,
      "tmpls" =>
      [{ "name" => "Card 1",
         "ord" => 0,
         "qfmt" => "{{Front}}",
         "afmt" => "{{FrontSide}}\n\n<hr id=answer>\n\n{{Back}}",
         "bqfmt" => "",
         "bafmt" => "",
         "did" => nil,
         "bfont" => "",
         "bsize" => 0 }],
      "flds" =>
      [{ "name" => "Front", "ord" => 0, "sticky" => false, "rtl" => false, "font" => "Arial", "size" => 20, "description" => "" },
       { "name" => "Back", "ord" => 1, "sticky" => false, "rtl" => false, "font" => "Arial", "size" => 20, "description" => "" }],
      "css" =>
      ".card {\n" \
      "    font-family: arial;\n" \
      "    font-size: 20px;\n" \
      "    text-align: center;\n" \
      "    color: black;\n" \
      "    background-color: white;\n" \
      "}\n",
      "latexPre" =>
      "\\documentclass[12pt]{article}\n" \
      "\\special{papersize=3in,5in}\n" \
      "\\usepackage[utf8]{inputenc}\n" \
      "\\usepackage{amssymb,amsmath}\n" \
      "\\pagestyle{empty}\n" \
      "\\setlength{\\parindent}{0in}\n" \
      "\\begin{document}\n",
      "latexPost" => "\\end{document}",
      "latexsvg" => false,
      "req" => [[0, "any", [0]]] }
  end

  ##
  # Returns the Ruby hash representing the default Basic and Reversed Card note type args
  def basic_and_reversed_card_model_hash
    { "id" => 1_676_902_364_662,
      "name" => "Basic (and reversed card)",
      "type" => 0,
      "mod" => 0,
      "usn" => 0,
      "sortf" => 0,
      "did" => nil,
      "tmpls" =>
    [{ "name" => "Card 1",
       "ord" => 0,
       "qfmt" => "{{Front}}",
       "afmt" => "{{FrontSide}}\n\n<hr id=answer>\n\n{{Back}}",
       "bqfmt" => "",
       "bafmt" => "",
       "did" => nil,
       "bfont" => "",
       "bsize" => 0 },
     { "name" => "Card 2",
       "ord" => 1,
       "qfmt" => "{{Back}}",
       "afmt" => "{{FrontSide}}\n\n<hr id=answer>\n\n{{Front}}",
       "bqfmt" => "",
       "bafmt" => "",
       "did" => nil,
       "bfont" => "",
       "bsize" => 0 }],
      "flds" =>
    [{ "name" => "Front", "ord" => 0, "sticky" => false, "rtl" => false, "font" => "Arial", "size" => 20, "description" => "" },
     { "name" => "Back", "ord" => 1, "sticky" => false, "rtl" => false, "font" => "Arial", "size" => 20, "description" => "" }],
      "css" =>
    ".card {\n" \
    "    font-family: arial;\n" \
    "    font-size: 20px;\n" \
    "    text-align: center;\n" \
    "    color: black;\n" \
    "    background-color: white;\n" \
    "}\n",
      "latexPre" =>
    "\\documentclass[12pt]{article}\n" \
    "\\special{papersize=3in,5in}\n" \
    "\\usepackage[utf8]{inputenc}\n" \
    "\\usepackage{amssymb,amsmath}\n" \
    "\\pagestyle{empty}\n" \
    "\\setlength{\\parindent}{0in}\n" \
    "\\begin{document}\n",
      "latexPost" => "\\end{document}",
      "latexsvg" => false,
      "req" => [[0, "any", [0]], [1, "any", [1]]] }
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Layout/LineContinuationLeadingSpace
end
# rubocop:enable RSpec/ContextWording
