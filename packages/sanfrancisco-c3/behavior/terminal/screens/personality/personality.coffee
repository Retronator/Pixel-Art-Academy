AM = Artificial.Mirage
AMu = Artificial.Mummification
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

# Note that we can't create the Personality variable since the class below would overwrite it.
Factors = LOI.Character.Behavior.Personality.Factors

class C3.Behavior.Terminal.Personality extends AM.Component
  @register 'SanFrancisco.C3.Behavior.Terminal.Personality'

  constructor: (@terminal) ->
    super
    
    @part = new ReactiveField null

    # We use this when the user wants to choose a different template (and templates wouldn't be shown by default).
    @forceShowTemplates = new ReactiveField false

    # We use this when the user wants to customize the options.
    @forceShowEditor = new ReactiveField false

  onCreated: ->
    super

    # Get the personality part from the character.
    @autorun (computation) =>
      behaviorPart = @terminal.screens.character.character()?.behavior.part
      personalityPart = behaviorPart.properties.personality.part

      @part personalityPart

    @hasCustomData = new ComputedField =>
      @part()?.hasData()

    @showTemplates = new ComputedField =>
      return true if @forceShowTemplates()
      return false if @forceShowEditor()

      # We default to showing available templates if the part hasn't been set yet.
      not @hasCustomData()

    # Subscribe to personality templates
    LOI.Character.Part.Template.forType.subscribe @, LOI.Character.Part.Types.Behavior.Personality.options.type

    @templateNameInput = new LOI.Components.TranslationInput
      placeholderText: => @translation "Name the template"

    @templateDescriptionInput = new LOI.Components.TranslationInput
      placeholderText: => @translation "Describe the personality profile"

  # Provide personality part to the factor axis.
  personalityPart: ->
    @part()

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
      template: template

  # Note that we can't name this helper 'template' since that would override Blaze Component template method.
  partTemplate: ->
    @part()?.options.dataLocation()?.template

  isOwnPartTemplate: ->
    return unless template = @partTemplate()

    userId = Meteor.userId()
    template.author?._id is userId

  isEditable: ->
    # We can edit the template if it's not using a template, or if the template is our own.
    not @partTemplate() or @isOwnPartTemplate()

  editableClass: ->
    'editable' if @isEditable()

  backButtonCallback: ->
    @closeScreen()

    # Instruct the back button to cancel closing (so it doesn't disappear).
    cancel: true

  closeScreen: ->
    if @forceShowTemplates()
      # We only need to not show templates in this case.
      @forceShowTemplates false

    else
      # We return back to the character screen.
      @terminal.switchToScreen @terminal.screens.character

  factors: ->
    [
      Factors[1]
      Factors[2]
      Factors[4]
      Factors[3]
      Factors[5]
    ]

  autoTraitsDataLocation: ->
    @part().properties.autoTraits.options.dataLocation

  autoTraits: ->
    # No support for auto-traits yet.
    # TODO: Implement auto-traits and remove this.
    return false
    
    # Auto traits are on by default.
    autoTraitsDataLocation = @autoTraitsDataLocation()
    autoTraitsDataLocation() ? true

  events: ->
    super.concat
      'click .done-button': @onClickDoneButton
      'click .replace-button': @onClickReplaceButton
      'click .save-as-template-button': @onClickSaveAsTemplateButton
      'click .unlink-template-button': @onClickUnlinkTemplateButton
      'click .custom-personality': @onClickCustomPersonality
      'click .delete-button': @onClickDeleteButton
      'click .template': @onClickTemplate

  onClickDoneButton: (event) ->
    @closeScreen()

  onClickReplaceButton: (event) ->
    @forceShowTemplates true
    @forceShowEditor false

  onClickSaveAsTemplateButton: (event) ->
    @part()?.options.dataLocation.createTemplate()

  onClickUnlinkTemplateButton: (event) ->
    @part()?.options.dataLocation.unlinkTemplate()

  onClickCustomPersonality: (event) ->
    # Clear current data at this node.
    @part()?.options.dataLocation.clear()

    @forceShowEditor true
    @forceShowTemplates false

  onClickDeleteButton: (event) ->
    # Delete current data at this node.
    @part()?.options.dataLocation.remove()

    # Return to previous screen.
    @closeScreen()

  onClickTemplate: (event) ->
    template = @currentData()

    @part()?.options.dataLocation.setTemplate template._id

    @forceShowTemplates false

  # Components

  class @AutoTraitsCheckbox extends AM.DataInputComponent
    @register 'SanFrancisco.C3.Behavior.Terminal.Personality.AutoTraitsCheckbox'

    constructor: ->
      super

      @type = AM.DataInputComponent.Types.Checkbox

    load: ->
      autoTraitsDataLocation = @data()

      # Auto traits are on by default.
      autoTraitsDataLocation() ? true

    save: (value) ->
      autoTraitsDataLocation = @data()

      autoTraitsDataLocation value
