AM = Artificial.Mirage
AMu = Artificial.Mummification
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Behavior.Terminal.Personality.Factor extends AM.Component
  @register 'SanFrancisco.C3.Behavior.Terminal.Personality.Factor'

  constructor: ->
    super

    @personalityPart = new ReactiveField null
    @part = new ReactiveField null

  onCreated: ->
    super

    # Get this factor part from the character.
    @autorun (computation) =>
      factor = @data()
      
      personality = @ancestorComponentOfType C3.Behavior.Terminal.Personality
      
      personalityPart = personality.part()
      @personalityPart personalityPart
      
      factorsProperty = personalityPart.properties.factors
      factorPart = factorsProperty.partsByOrder()[factor.options.type]

      unless factorPart
        # The factor part does not exist yet (since there is no data for it), so we create it.
        Tracker.nonreactive =>
          partDataLocation = factorsProperty.options.dataLocation.child factor.options.type

          partDataLocation.saveMetaData
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
    LOI.Character.Part.Template.forType.subscribe @, LOI.Character.Part.Types.Behavior.Personality.Factor.options.type

    @templateNameInput = new LOI.Components.TranslationInput
      placeholderText: => @translation "Name the template"

  renderTemplateNameInput: ->
    @templateNameInput.renderComponent @currentComponent()

  templates: ->
    factor = @data()

    LOI.Character.Part.Template.documents.find
      type: LOI.Character.Part.Types.Behavior.Personality.Factor.options.type
      'data.fields.index.value': factor.options.type
    ,
      sort:
        'name.translations.best.text': 1

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
    return unless template = @partTemplate()

    userId = Meteor.userId()
    template.author?._id is userId

  isEditable: ->
    # We can edit this factor if the personality is editable.
    personality = @ancestorComponentOfType C3.Behavior.Terminal.Personality
    personality.isEditable()

  editableClass: ->
    'editable' if @isEditable()

  traits: ->
    factorPart = @part()
    factorPart.properties.traits.toString()

  areTraitsEditable: ->
    # We can edit the factor's traits if it's not a template, or it's our own template.
    not @partTemplate() or @isOwnPartTemplate()

  events: ->
    super.concat
      'click .factor-edit-traits-button': @onClickEditTraitsButton
      'click .factor-save-as-template-button': @onClickSaveAsTemplateButton
      'click .factor-unlink-template-button': @onClickUnlinkTemplateButton
      'click .factor-reset-button': @onClickResetButton
      'click .traits': @onClickTraits

  onClickEditTraitsButton: (event) ->
    @onClickTraits event

  onClickSaveAsTemplateButton: (event) ->
    @part()?.options.dataLocation.createTemplate()

  onClickUnlinkTemplateButton: (event) ->
    @part()?.options.dataLocation.unlinkTemplate()

  onClickResetButton: (event) ->
    # Delete current data at this node.
    @part()?.options.dataLocation.remove()

  onClickTraits: (event) ->
    factor = @data()

    terminal = @ancestorComponentOfType C3.Behavior.Terminal

    terminal.screens.traits.setFactor factor, @part, @personalityPart
    terminal.switchToScreen terminal.screens.traits

  # Components

  class @TemplateDropdown extends AM.DataInputComponent
    @register 'SanFrancisco.C3.Behavior.Terminal.Personality.Factor.TemplateDropdown'

    constructor: ->
      super

      @type = AM.DataInputComponent.Types.Select

    onCreated: ->
      super

      @factorComponent = @ancestorComponentOfType C3.Behavior.Terminal.Personality.Factor

    options: ->
      options = [
        name: 'Custom'
        value: ''
      ]

      for template in @factorComponent.templates().fetch()
        options.push
          name: @translateTranslation template.name
          value: template._id

      options

    load: ->
      @factorComponent.partTemplate()?._id

    save: (value) ->
      dataLocation = @factorComponent.part().options.dataLocation

      if value isnt ''
        dataLocation.setTemplate value

      else
        dataLocation.unlinkTemplate()

  class @Axis extends AM.Component
    @register 'SanFrancisco.C3.Behavior.Terminal.Personality.Factor.Axis'

    onCreated: ->
      super

      @terminal = @ancestorComponentOfType C3.Behavior.Terminal

    part: ->
      partProvider = @ancestorComponentWith (component) -> component.personalityPart?
      partProvider.personalityPart()

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

      return unless personality = @part()
      factorPower = personality.factorPowers()[factor.options.type]

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
