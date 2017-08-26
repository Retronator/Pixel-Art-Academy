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

    # Get this factor part from the character.
    @autorun (computation) =>
      factor = @data()
      
      personality = @ancestorComponentOfType C3.Behavior.Terminal.Personality
      factorsProperty = personality.part().properties.factors
      factorPart = factorsProperty.partsByOrder[factor.options.type]

      unless factorPart
        # The factor part does not exist yet (since there is no data for it), so we create it.
        Tracker.nonreactive =>
          partDataLocation = factorsProperty.options.dataLocation.child factor.options.type

          partDataLocation.setMetaData
            type: factorsProperty.options.type

          factorPartClass = LOI.Character.Part.getClassForType factorsProperty.options.type
          factorPart = factorPartClass.create
            dataLocation: partDataLocation
            parent: @

          # Set the factor index.
          factorPart.properties.index.options.dataLocation factor.options.type

      @part factorPart

    @hasCustomData = new ComputedField =>
      @part()?.options.dataLocation()?.data()

    # Subscribe to factor templates.
    LOI.Character.Part.Template.forType.subscribe @, 'Behavior.Personality.Factor'

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
      type: LOI.Character.Part.Types.Behavior.Personality.options.type

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

  traits: ->
    factorPart = @part()
    traits = factorPart.properties.traits.parts()
    return unless traits.length

    enabledTraits = _.filter traits, (trait) -> trait.properties.weight.options.dataLocation() > 0

    traitNames = (_.capitalize trait.properties.key.options.dataLocation() for trait in enabledTraits)

    traitNames.join ', '

  events: ->
    super.concat
      'click .factor-save-as-template-button': @onClickSaveAsTemplateButton
      'click .factor-unlink-template-button': @onClickUnlinkTemplateButton
      'click .factor-reset-button': @onClickResetButton
      'click .traits': @onClickTraits

  onClickSaveAsTemplateButton: (event) ->
    @part()?.options.dataLocation.createTemplate()

  onClickUnlinkTemplateButton: (event) ->
    @part()?.options.dataLocation.unlinkTemplate()

  onClickResetButton: (event) ->
    # Delete current data at this node.
    @part()?.options.dataLocation.remove()

    # Pop this part off the stack.
    @popPart()

  onClickTraits: (event) ->
    factor = @data()

    terminal = @ancestorComponentOfType C3.Behavior.Terminal

    terminal.screens.traits.setFactor factor, @part
    terminal.switchToScreen terminal.screens.traits

  # Components

  class @TemplateDropdown extends AM.DataInputComponent
    constructor: ->
      super

      @type = AM.DataInputComponent.Types.Select

  class @Axis extends AM.Component
    @register 'SanFrancisco.C3.Behavior.Terminal.Personality.Factor.Axis'

    onCreated: ->
      super

      @terminal = @ancestorComponentOfType C3.Behavior.Terminal
      @behavior = @terminal.screens.character.character()?.behavior
  
    leftFactorName: -> @_factorName false
    rightFactorName: -> @_factorName true
  
    _factorName: (right) ->
      @_getFactorSide(right).key
  
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

    leftIndicatorStyle: -> @_indicatorStyle false
    rightIndicatorStyle: -> @_indicatorStyle true

    _indicatorStyle: (right) ->
      return unless palette = LOI.palette()

      percentage = @_indicatorPositionPercentage right

      colorData = @_getFactorSide(right).color
      borderColor = palette.color colorData.hue, colorData.shade
      backgroundColor = palette.color colorData.hue, colorData.shade - 2

      style =
        borderColor: "##{borderColor.getHexString()}"
        backgroundColor: "##{backgroundColor.getHexString()}"

      if right
        style.left = "#{percentage}%"

      else
        style.right = "#{percentage}%"

      style

    _indicatorPositionPercentage: (right) ->
      factor = @data()

      factorPower = @behavior.part.properties.personality.part.factorPowers()[factor.options.type]

      power = if right is not factor.options.displayReversed then factorPower.positive else factorPower.negative
      Math.min 100, power * 10

    leftProgressBarStyle: -> @_progressBarStyle false
    rightProgressBarStyle: -> @_progressBarStyle true

    _progressBarStyle: (right) ->
      return unless palette = LOI.palette()

      percentage = @_indicatorPositionPercentage right

      colorData = @_getFactorSide(right).color
      backgroundColor = palette.color colorData.hue, colorData.shade - 2

      width: "#{percentage}%"
      backgroundColor: "##{backgroundColor.getHexString()}"
