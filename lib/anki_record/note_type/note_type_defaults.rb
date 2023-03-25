# frozen_string_literal: true

module AnkiRecord
  module NoteTypeDefaults # :nodoc:
    private

      def default_note_type_sort_field
        0
      end

      def default_css
        <<~CSS
          .card {
            color: black;
            background-color: transparent;
            text-align: center;
          }
        CSS
      end

      def default_latex_preamble
        <<~LATEX_PRE
          \\documentclass[12pt]{article}
          \\special{papersize=3in,5in}
          \\usepackage{amssymb,amsmath}
          \\pagestyle{empty}
          \\setlength{\\parindent}{0in}
          \\begin{document}
        LATEX_PRE
      end

      def default_latex_postamble
        <<~LATEX_POST
          \\end{document}
        LATEX_POST
      end
  end
end
