# frozen_string_literal: true

require "pry"

require_relative "card_template"
require_relative "helpers/shared_constants_helper"
require_relative "helpers/time_helper"
require_relative "note_field"

module AnkiRecord
  ##
  # NoteType represents an Anki note type (also called a model)
  class NoteType
    include AnkiRecord::SharedConstantsHelper
    include AnkiRecord::TimeHelper
    NEW_NOTE_TYPE_SORT_FIELD = 0
    private_constant :NEW_NOTE_TYPE_SORT_FIELD

    ##
    # The collection object that the note type belongs to
    attr_reader :collection

    ##
    # The id of the note type
    attr_reader :id

    ##
    # The name of the note type
    attr_accessor :name

    ##
    # A boolean that indicates if this note type is a cloze-deletion note type
    attr_accessor :cloze

    ##
    # The CSS styling of the note type
    attr_reader :css

    ##
    # The LaTeX preamble of the note type
    attr_reader :latex_preamble

    ##
    # The LaTeX postamble of the note type
    attr_reader :latex_postamble

    ##
    # A boolean probably related to something with LaTeX and SVG.
    #
    # TODO: Investigate what this does
    attr_reader :latex_svg

    ##
    # An array of the card template objects belonging to the note type
    attr_reader :card_templates

    ##
    # An array of the field names of the card template
    attr_reader :fields

    ##
    # TODO: Investigate the meaning of the deck id of a note type
    attr_reader :deck_id

    ##
    # TODO: Investigate the meaning of tags of a note type
    attr_reader :tags

    ##
    # Instantiates a new note type
    def initialize(collection:, name: nil, cloze: false, args: nil)
      raise ArgumentError unless (name && args.nil?) || (args && args["name"])

      @collection = collection

      if args
        setup_note_type_instance_variables_from_existing(args: args)
      else
        setup_note_type_instance_variables(name: name, cloze: cloze)
      end
    end

    ##
    # Creates a new field and adds it to this note type's fields
    #
    # The field is an instance of AnkiRecord::NoteField
    def new_note_field(name:)
      # TODO: Raise an exception if the name is already used by a field in this note type
      @fields << AnkiRecord::NoteField.new(note_type: self, name: name)
    end

    ##
    # Create a new card template and adds it to this note type's templates
    #
    # The card template is an instance of AnkiRecord::CardTemplate
    def new_card_template(name:)
      # TODO: Raise an exception if the name is already used by a template in this note type
      @card_templates << AnkiRecord::CardTemplate.new(note_type: self, name: name)
    end

    ##
    # The allowed field names of the note in snake_case
    #
    # TODO: make this more robust... what happens when the note type name has non-alphabetic characters?
    def snake_case_field_names
      @fields.map { |field| field.name.downcase.gsub(" ", "_") }
    end

    private

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def setup_note_type_instance_variables_from_existing(args:)
        @id = args["id"]
        @name = args["name"]
        @cloze = args["type"] == 1
        @last_modified_time = args["mod"]
        @usn = args["usn"]
        @sort_field = args["sortf"]
        @deck_id = args["did"]
        @fields = args["flds"].map { |fld| NoteField.new(note_type: self, args: fld) }
        @card_templates = args["tmpls"].map { |tmpl| CardTemplate.new(note_type: self, args: tmpl) }
        @css = args["css"]
        @latex_preamble = args["latexPre"]
        @latex_postamble = args["latexPost"]
        @latex_svg = args["latexsvg"]
        @req = args["req"]
        @tags = args["tags"]
        @vers = args["vers"]
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      # rubocop:disable Metrics/MethodLength
      def setup_note_type_instance_variables(name:, cloze:)
        @id = milliseconds_since_epoch
        @name = name
        @cloze = cloze
        @last_modified_time = seconds_since_epoch
        @usn = NEW_OBJECT_USN
        @sort_field = NEW_NOTE_TYPE_SORT_FIELD
        @deck_id = nil
        @fields = []
        @card_templates = []
        @css = default_css
        @latex_preamble = default_latex_preamble
        @latex_postamble = default_latex_postamble
        @latex_svg = false
        @req = nil
        @tags = []
        @vers = []
      end
      # rubocop:enable Metrics/MethodLength

      def default_css
        <<-CSS
        .card {
          color: black;
          background-color: transparent;
          text-align: center;
        }
        CSS
      end

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

      def default_latex_postamble
        <<-LATEX_POST
        \\end{document}
        LATEX_POST
      end
  end
end
