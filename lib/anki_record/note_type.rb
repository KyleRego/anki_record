# frozen_string_literal: true

require "pry"
require_relative "field"
require_relative "template"
require_relative "helpers/time_helper"

module AnkiRecord
  ##
  # NoteType represents an Anki note type (also called a model)
  class NoteType
    include AnkiRecord::TimeHelper
    NEW_NOTE_TYPE_USN = -1
    NEW_NOTE_TYPE_SORT_FIELD = 0
    private_constant :NEW_NOTE_TYPE_USN, :NEW_NOTE_TYPE_SORT_FIELD

    attr_accessor :name, :cloze_type, :css
    attr_reader :id, :templates, :fields

    ##
    # Instantiates a new note type
    def initialize(name:, cloze: false)
      raise ArgumentError unless name

      setup_note_type_instance_variables(name: name, cloze: cloze)
    end

    ##
    # Create a new field and adds it to this note type's fields
    #
    # The field is an instance of AnkiRecord::Field
    def new_note_field(name:)
      # TODO: Check if name already used by a field in this note type
      @fields << AnkiRecord::Field.new(note_type: self, name: name)
    end

    ##
    # Create a new card template and adds it to this note type's templates
    #
    # The card template is an instance of AnkiRecord::Template
    def new_card_template(name:)
      # TODO: Check if name already used by a template in this note type
      @templates << AnkiRecord::Template.new(note_type: self, name: name)
    end

    private

      # rubocop:disable Metrics/MethodLength
      def setup_note_type_instance_variables(name:, cloze:)
        @id = milliseconds_since_epoch
        @name = name
        @cloze_type = cloze
        @last_modified_time = seconds_since_epoch
        @usn = NEW_NOTE_TYPE_USN
        @sort_field = NEW_NOTE_TYPE_SORT_FIELD
        @deck_id = nil
        @templates = []
        @fields = []
        @css = default_css
        @latex_preamble = default_latex_preamble
        @latex_postamble = default_latex_postamble
        @latex_svg = false
        @req = nil
        @tags = []
        @vers = []
      end
      # rubocop:enable Metrics/MethodLength

      # TODO: use constant here
      def default_css
        <<-CSS
        .card {
          color: black;
          background-color: transparent;
          text-align: center;
        }
        CSS
      end

      # TODO: use constant here
      def default_latex_preamble
        <<-LATEX_PRE
        \\documentclass[12pt]{article}
        \\special{papersize=3in,5in}
        \\usepackage{amssymb,amsmath}
        \\pagestyle{empty}
        \\setlength{\\parindent}{0in}
        \\begin{document}
        LATEX_PRE
      end

      # TODO: use constant here
      def default_latex_postamble
        <<-LATEX_POST
        \\end{document}
        LATEX_POST
      end
  end
end
