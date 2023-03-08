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
    # A boolean (probably) related to something related to LaTeX and SVG
    attr_reader :latex_svg

    ##
    # The array of the card template objects of the note type
    attr_reader :card_templates

    ##
    # The array of the note field objects of the note type
    attr_reader :note_fields

    ##
    # TODO: wat is this
    attr_reader :deck_id

    ##
    # TODO: wat is this
    attr_reader :tags

    def initialize(collection:, name: nil, cloze: false, args: nil)
      raise ArgumentError unless (name && args.nil?) || (args && args["name"])

      @collection = collection

      if args
        setup_note_type_instance_variables_from_existing(args: args)
      else
        setup_note_type_instance_variables(name: name, cloze: cloze)
      end

      @collection.add_note_type self
    end

    def save
      collection_models_hash = JSON.parse(collection.anki_package.execute("select models from col;").first["models"])
      collection_models_hash[id] = to_h
      new_collection_models_json = JSON.generate(collection_models_hash)
      # TODO: Refactor to prevent injection
      collection.anki_package.execute("update col set models = '#{new_collection_models_json}' where id = '#{collection.id}'")
    end

    def to_h # :nodoc:
      { id: @id,
        name: @name,
        type: @cloze,
        mod: @last_modified_time,
        usn: @usn,
        sort_field:
        @sort_field,
        did: @deck_id }
      # tmpls:
      # @note_fields.map(&:to_h) # TODO: finish this
    end

    ##
    # Returns the note type object's card template with name +name+ or nil if it is not found
    def find_card_template_by(name:)
      card_templates.find { |template| template.name == name }
    end

    ##
    # The field names of the note type ordered by their ordinal values
    def field_names_in_order
      @note_fields.sort_by(&:ordinal_number).map(&:name)
    end

    def snake_case_field_names # :nodoc:
      field_names_in_order.map { |field_name| field_name.downcase.gsub(" ", "_") }
    end

    ##
    # The name of the field used to sort notes of the note type in the Anki browser
    def sort_field_name
      @note_fields.find { |field| field.ordinal_number == @sort_field }&.name
    end

    def snake_case_sort_field_name # :nodoc:
      sort_field_name.downcase.gsub(" ", "_")
    end

    ##
    # The allowed field_name values in {{field_name}} of the note type's card templates' question format
    #
    # These are the note type's fields' names, and if the note type is a cloze type,
    # these also include the note type's fields' names prepended with 'cloze:'.
    #
    # TODO: research if other special field names like e.g. 'FrontSide' are allowed
    def allowed_card_template_question_format_field_names
      allowed = field_names_in_order
      cloze ? allowed + field_names_in_order.map { |field_name| "cloze:#{field_name}" } : allowed
    end

    ##
    # The allowed field_name values in {{field_name}} of the note type's card templates' answer format
    #
    # These are the note type's fields' names, and if the note type is a cloze type,
    # these also include the note type's fields' names prepended with 'cloze:'.
    #
    # TODO: research if other special field names like e.g. 'FrontSide' are allowed
    def allowed_card_template_answer_format_field_names
      allowed_card_template_question_format_field_names + ["FrontSide"]
    end

    def add_note_field(note_field) # :nodoc: TODO: RSpec example for ArgumentError
      raise ArgumentError unless note_field.instance_of?(AnkiRecord::NoteField)

      @note_fields << note_field
    end

    def add_card_template(card_template) # :nodoc: TODO: RSpec example for ArgumentError
      raise ArgumentError unless card_template.instance_of?(AnkiRecord::CardTemplate)

      @card_templates << card_template
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
        @note_fields = []
        args["flds"].each { |fld| NoteField.new(note_type: self, args: fld) }
        @card_templates = []
        args["tmpls"].each { |tmpl| CardTemplate.new(note_type: self, args: tmpl) }
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
        @note_fields = []
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
