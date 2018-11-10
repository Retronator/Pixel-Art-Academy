AM = Artificial.Mirage
AMu = Artificial.Mummification
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.AvatarPart extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.AvatarPart'

  constructor: (@terminal) ->
    super arguments...

    # We need these fields in the constructor, because they're being set right away.
    @part = new ReactiveField null
    @previewPart = new ReactiveField null

    # We use this when the user wants to choose a different template (and templates wouldn't be shown by default).
    @forceShowTemplates = new ReactiveField false

    # We use this when the user wants to customize the options.
    @forceShowEditor = new ReactiveField false

    @partStack = []

  onCreated: ->
    super arguments...

    @hasCustomData = new ComputedField =>
      @part()?.options.dataLocation()?.data()

    @showTemplates = new ComputedField =>
      return true if @forceShowTemplates()
      return false if @forceShowEditor()

      # We default to showing available templates if the part hasn't been set yet.
      not @hasCustomData()

    @type = new ComputedField =>
      @part()?.options.type

    @templateNameInput = new LOI.Components.TranslationInput
      placeholderText: => @translation "Name your template"

    @templateDescriptionInput = new LOI.Components.TranslationInput
      placeholderText: => @translation "Describe your design"

    @hoveredTemplate = new ReactiveField null

  renderTemplateNameInput: ->
    @templateNameInput.renderComponent @currentComponent()

  renderTemplateDescriptionInput: ->
    @templateDescriptionInput.renderComponent @currentComponent()

  templates: ->
    return unless type = @type()

    LOI.Character.Part.Template.documents.find {type},
      sort:
        'name.translations.best.text': 1

  templatePart: ->
    template = @currentData()
    return unless part = @part()

    dataField = AMu.Hierarchy.create
      templateClass: LOI.Character.Part.Template
      load: => template

    part.create
      dataLocation: new AMu.Hierarchy.Location
        rootField: dataField

  pushPart: (part, previewPart) ->
    # Put current part on the stack
    currentPart = @part()
    @partStack.push currentPart if currentPart

    # Set new part as active.
    @part part

    # Replace the preview part, if it's present.
    @previewPart previewPart if previewPart

    # Reset force modes.
    @forceShowTemplates false
    @forceShowEditor false

  popPart: ->
    # Get the last part from the stack.
    lastPart = @partStack.pop()

    @part lastPart

  partProperties: ->
    _.values @part().properties

  # Note that we can't name this helper 'template' since that would override Blaze Component template method.
  partTemplate: ->
    @part()?.options.dataLocation()?.template

  isOwnPartTemplate: ->
    userId = Meteor.userId()
    template = @partTemplate()
    template.author?._id is userId

  isEditable: ->
    # User can edit the part if it is not a template or if the template belongs to them.
    @canCreateNew() and (not @partTemplate() or @isOwnPartTemplate())

  editableClass: ->
    'editable' if @isEditable()

  canCreateNew: ->
    # Non-admin user can create all parts but shapes.
    return true unless @part() instanceof LOI.Character.Avatar.Parts.Shape

    Retronator.user()?.hasItem Retronator.Store.Items.CatalogKeys.Retronator.Admin

  backButtonCallback: ->
    @closePart()

    # Instruct the back button to cancel closing (so it doesn't disappear).
    cancel: true

  closePart: ->
    if @forceShowTemplates()
      # We only need to not show templates in this case.
      @forceShowTemplates false

    else
      # Pop this part off the stack.
      @popPart()

      # We return back to the character screen if there's no more parts to show.
      @terminal.switchToScreen @terminal.screens.character unless @part()

  partClass: ->
    return unless part = @part()
    _.kebabCase part.options.type

  propertyClass: ->
    property = @currentData()
    _.kebabCase property.options.name

  avatarPreviewOptions: ->
    rotatable: true
    viewingAngle: @terminal.viewingAngle

  events: ->
    super(arguments...).concat
      'click .done-button': @onClickDoneButton
      'click .replace-button': @onClickReplaceButton
      'click .save-as-template-button': @onClickSaveAsTemplateButton
      'click .unlink-template-button': @onClickUnlinkTemplateButton
      'click .new-part-button': @onClickNewPartButton
      'click .delete-button': @onClickDeleteButton
      'click .template': @onClickTemplate
      'mouseenter .template': @onMouseEnterTemplate
      'mouseleave .template': @onMouseLeaveTemplate

  onClickDoneButton: (event) ->
    # See if we've set any data to this part and delete it if not.
    partDataLocation = @part()?.options.dataLocation
    partDataLocation.remove() unless partDataLocation()

    @closePart()

  onClickReplaceButton: (event) ->
    @forceShowTemplates true
    @forceShowEditor false
    @hoveredTemplate null

  onClickSaveAsTemplateButton: (event) ->
    @part()?.options.dataLocation.createTemplate()

  onClickUnlinkTemplateButton: (event) ->
    @part()?.options.dataLocation.unlinkTemplate()

  onClickNewPartButton: (event) ->
    # Delete current data at this node.
    @part()?.options.dataLocation.clear()

    @forceShowEditor true
    @forceShowTemplates false

  onClickDeleteButton: (event) ->
    # Delete current data at this node.
    @part()?.options.dataLocation.remove()

    # Pop this part off the stack.
    @closePart()

  onClickTemplate: (event) ->
    template = @currentData()

    @part()?.options.dataLocation.setTemplate template._id

    @forceShowTemplates false
    @hoveredTemplate null

  onMouseEnterTemplate: (event) ->
    template = @currentData()

    @hoveredTemplate template

  onMouseLeaveTemplate: (event) ->
    @hoveredTemplate null
