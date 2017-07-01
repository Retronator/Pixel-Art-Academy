AM = Artificial.Mirage
AMu = Artificial.Mummification
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Behavior.Terminal.Personality.Factor extends AM.Component
  @register 'SanFrancisco.C3.Behavior.Terminal.Personality.Factor'

  constructor: ->
    super
    
    @part = new ReactiveField null

  onCreated: ->
    super

    # Get the behavior part from the character.
    @autorun (computation) =>
      factor = @data()
      
      personality = @ancestorComponentOfType C3.Behavior.Terminal.Personality
      factorParts = personality.part().properties.factors.parts()
      
      factorPart = _.find factorParts, (factorPart) => factorPart.option.type is factor.options.type

      console.log "p", factorPart, factorParts

      @part factorPart

    @hasCustomData = new ComputedField =>
      @part()?.options.dataLocation()?.data()

    # Subscribe to this factor's templates
    @autorun (computation) =>
      factor = @data()
      LOI.Character.Part.Template.forType.subscribe @, factor.options.type

    @templateNameInput = new LOI.Components.TranslationInput
      placeholderText: => @translation "Name the template"

    @templateDescriptionInput = new LOI.Components.TranslationInput
      placeholderText: => @translation "Describe the personality profile"

  renderTemplateNameInput: ->
    @templateNameInput.renderComponent @currentComponent()

  renderTemplateDescriptionInput: ->
    @templateDescriptionInput.renderComponent @currentComponent()

  templates: ->
    LOI.Character.Part.Template.documents.find
      type: LOI.Character.Part.Types.Personality.options.type

  templatePart: ->
    template = @currentData()
    part = @part()

    dataField = AMu.Hierarchy.create
      templateClass: LOI.Character.Part.Template
      load: => template

    part.create
      dataLocation: new AMu.Hierarchy.Location
        rootField: dataField

  # Note that we can't name this helper 'template' since that would override Blaze Component template method.
  partTemplate: ->
    @part()?.options.dataLocation()?.template

  isOwnPartTemplate: ->
    userId = Meteor.userId()
    template = @partTemplate()
    template.author._id is userId

  leftFactorName: -> @_factorName false
  rightFactorName: -> @_factorName true

  _factorName: (right) ->
    @_getFactorSide(right).name

  _getFactorSide: (right) ->
    factor = @data()

    if right is not factor.options.displayReversed then factor.options.positive else factor.options.negative

  leftFactorStyle: -> @_factorStyle false
  rightFactorStyle: -> @_factorStyle true

  _factorStyle: (right) ->
    return unless palette = LOI.palette()

    colorData = @_getFactorSide(right).color
    color = palette.color colorData.hue, colorData.shade

    color: "##{color.getHexString()}"

  events: ->
    super.concat
      'click .factor-save-as-template-button': @onClickSaveAsTemplateButton
      'click .factor-unlink-template-button': @onClickUnlinkTemplateButton
      'click .factor-reset-button': @onClickResetButton

  onClickSaveAsTemplateButton: (event) ->
    @part()?.options.dataLocation.createTemplate()

  onClickUnlinkTemplateButton: (event) ->
    @part()?.options.dataLocation.unlinkTemplate()

  onClickResetButton: (event) ->
    # Delete current data at this node.
    @part()?.options.dataLocation.remove()

    # Pop this part off the stack.
    @popPart()

  # Components

  class @TemplateDropdown extends AM.DataInputComponent
    constructor: ->
      super

      @type = AM.DataInputComponent.Types.Select
