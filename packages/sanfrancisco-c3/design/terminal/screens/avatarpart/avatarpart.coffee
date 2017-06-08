AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.AvatarPart extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.AvatarPart'

  constructor: (@terminal) ->
    super

    # We need these fields in the constructor, because they're being set right away.
    @part = new ReactiveField null

    # We use this when the user wants to choose a different template (and templates wouldn't be shown by default).
    @forceShowTemplates = new ReactiveField false

    # We use this when the user wants to customize the options.
    @forceShowEditor = new ReactiveField false

  onCreated: ->
    super

    @hasCustomData = new ComputedField =>
      @part()?.options.dataLocation()?.data()

    @showTemplates = new ComputedField =>
      return true if @forceShowTemplates()
      return false if @forceShowEditor()

      # We default to showing available templates if the part hasn't been set yet.
      not @hasCustomData()

    @type = new ComputedField =>
      @part()?.options.type
      
    # Subscribe to character part templates of the given type.
    @autorun (computation) =>
      return unless type = @type()

      LOI.Character.Part.Template.forType.subscribe @, type

    @templateNameInput = new LOI.Components.TranslationInput
      placeholderText: => @translation "Name your template"

    @templateDescriptionInput = new LOI.Components.TranslationInput
      placeholderText: => @translation "Describe your design"

  renderTemplateNameInput: ->
    @templateNameInput.renderComponent @currentComponent()

  renderTemplateDescriptionInput: ->
    @templateDescriptionInput.renderComponent @currentComponent()

  templates: ->
    return unless type = @type()

    LOI.Character.Part.Template.documents.find {type}

  setPart: (part) ->
    @part part

    # Reset force modes.
    @forceShowTemplates false
    @forceShowEditor false

  partProperties: ->
    _.values @part().properties

  # Note that we can't name this helper 'template' since that would override Blaze Component template method.
  partTemplate: ->
    @part().options.dataLocation()?.template

  isOwnPartTemplate: ->
    userId = Meteor.userId()
    template = @partTemplate()
    template.author._id is userId

  events: ->
    super.concat
      'click .done-button': @onClickDoneButton
      'click .replace-button': @onClickReplaceButton
      'click .save-as-template-button': @onClickSaveAsTemplateButton
      'click .unlink-template-button': @onClickUnlinkTemplateButton
      'click .new-part-button': @onClickNewPartButton
      'click .template': @onClickTemplate

  onClickDoneButton: (event) ->
    if @forceShowTemplates()
      # We only need to not show templates in this case.
      @forceShowTemplates false

    else
      # We return back to the character screen.
      @terminal.switchToScreen @terminal.screens.character

  onClickReplaceButton: (event) ->
    @forceShowTemplates true
    @forceShowEditor false

  onClickSaveAsTemplateButton: (event) ->
    @part()?.options.dataLocation.createTemplate()

  onClickUnlinkTemplateButton: (event) ->
    @part()?.options.dataLocation.unlinkTemplate()

  onClickNewPartButton: (event) ->
    # Delete current data at this node.
    @part()?.options.dataLocation.clear()

    @forceShowEditor true
    @forceShowTemplates false

  onClickTemplate: (event) ->
    template = @currentData()

    @part()?.options.dataLocation.setTemplate template._id

    @forceShowTemplates false
