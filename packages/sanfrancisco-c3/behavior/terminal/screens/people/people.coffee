AM = Artificial.Mirage
AMu = Artificial.Mummification
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Person = LOI.Character.Behavior.Person

class C3.Behavior.Terminal.People extends AM.Component
  @register 'SanFrancisco.C3.Behavior.Terminal.People'

  constructor: (@terminal) ->
    super

    @property = new ReactiveField null

    # We use this when the user wants to choose a different template (and templates wouldn't be shown by default).
    @forceShowTemplates = new ReactiveField false

    # We use this when the user wants to customize the options.
    @forceShowEditor = new ReactiveField false

  onCreated: ->
    super

    # Get the people part from the character.
    @autorun (computation) =>
      behaviorPart = @terminal.screens.character.character()?.behavior.part
      peopleProperty = behaviorPart.properties.environment.part.properties.people

      @property peopleProperty

    @hasCustomData = new ComputedField =>
      @property()?.options.dataLocation()?.data()

    @showTemplates = new ComputedField =>
      return true if @forceShowTemplates()
      return false if @forceShowEditor()

      # We default to showing available templates if the part hasn't been set yet.
      not @hasCustomData()

    # Subscribe to people templates.
    LOI.Character.Part.Template.forType.subscribe @, LOI.Character.Part.Types.Behavior.Environment.options.properties.people.options.templateType

    @templateNameInput = new LOI.Components.TranslationInput
      placeholderText: => @translation "Name the people configuration"

    @templateDescriptionInput = new LOI.Components.TranslationInput
      placeholderText: => @translation "Describe what kind of people are in the configuration"

  renderTemplateNameInput: ->
    @templateNameInput.renderComponent @currentComponent()

  renderTemplateDescriptionInput: ->
    @templateDescriptionInput.renderComponent @currentComponent()

  templates: ->
    LOI.Character.Part.Template.documents.find
      type: LOI.Character.Part.Types.Behavior.Environment.options.properties.people.options.templateType

  templateParts: ->
    template = @currentData()
    property = @property()

    dataField = AMu.Hierarchy.create
      templateClass: LOI.Character.Part.Template
      load: => template

    property.create
      dataLocation: new AMu.Hierarchy.Location
        rootField: dataField

  # Note that we can't name this helper 'template' since that would override Blaze Component template method.
  partsTemplate: ->
    @property()?.options.dataLocation()?.template

  isOwnPartsTemplate: ->
    userId = Meteor.userId()
    template = @partsTemplate()
    template.author._id is userId

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
      @terminal.switchToScreen @terminal.screens.environment

  people: ->
    @property()?.parts()

  events: ->
    super.concat
      'click .done-button': @onClickDoneButton
      'click .replace-button': @onClickReplaceButton
      'click .save-as-template-button': @onClickSaveAsTemplateButton
      'click .unlink-template-button': @onClickUnlinkTemplateButton
      'click .custom-people-button': @onClickCustomPeopleButton
      'click .delete-button': @onClickDeleteButton
      'click .template': @onClickTemplate
      'click .add-person-button': @onClickAddPersonButton

  onClickDoneButton: (event) ->
    @closeScreen()

  onClickReplaceButton: (event) ->
    @forceShowTemplates true
    @forceShowEditor false

  onClickSaveAsTemplateButton: (event) ->
    @property()?.options.dataLocation.createTemplate()

  onClickUnlinkTemplateButton: (event) ->
    @property()?.options.dataLocation.unlinkTemplate()

  onClickCustomPeopleButton: (event) ->
    # Delete current data at this node.
    @property()?.options.dataLocation.clear()

    @forceShowEditor true
    @forceShowTemplates false

  onClickDeleteButton: (event) ->
    # Delete current data at this node.
    @property()?.options.dataLocation.remove()

    # Pop this part off the stack.
    @popPart()

  onClickTemplate: (event) ->
    template = @currentData()

    @property()?.options.dataLocation.setTemplate template._id

    @forceShowTemplates false

    # Return to previous item where we will see the result of choosing this part.
    @closeScreen()

  onClickAddPersonButton: (event) ->
    personType = LOI.Character.Part.Types.Behavior.Environment.Person.options.type
    newPart = @property().newPart personType
    newPart.options.dataLocation {}

  # Components
