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
    @previewOptions = new ReactiveField null

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

    # We must provide a preview part even though we send the custom renderer because avatar part
    # preview component determines which preview type to use based on the part sent in the data.
    @previewPart = new ComputedField =>
      @terminal.screens.character.character()?.avatar or @part()

  renderTemplateNameInput: ->
    @templateNameInput.renderComponent @currentComponent()

  renderTemplateDescriptionInput: ->
    @templateDescriptionInput.renderComponent @currentComponent()

  templateGroups: ->
    return unless type = @type()

    templates = LOI.Character.Part.Template.documents.fetch
      type: type
      latestVersion:
        $exists: true
    ,
      sort:
        'name.translations.best.text': 1

    return [{templates, lastGroup: true}] if templates.length < 30

    groups = []
    currentGroup = title: null
    lastTemplate = null

    for template in templates
      [prefix, ..., suffix] = template.name.translations.best.text.split ' '

      # See if this template is a middle/behind counterpart.
      if lastTemplate and suffix in ['middle', 'behind']
        if template.name.translations.best.text is "#{lastTemplate.name.translations.best.text} #{suffix}"
          # Add the counterpart template to the main template.
          lastTemplate.counterpartTemplates ?= []
          lastTemplate.counterpartTemplates.push template
          continue

      # See if this template should start a new group.
      if prefix is currentGroup.title
        # The prefix is still the same, so add the template to existing group.
        currentGroup.templates.push template

      else
        # Create a new group.
        currentGroup =
          title: prefix
          templates: [template]

        groups.push currentGroup

      lastTemplate = template

    groups.push
      title: 'Custom'
      templates: []
      lastGroup: true

    groups

  templatePart: ->
    template = @currentData()
    return unless part = @part()

    dataField = AMu.Hierarchy.create
      templateClass: LOI.Character.Part.Template
      load: => node: template.latestVersion.data

    part.create
      dataLocation: new AMu.Hierarchy.Location
        rootField: dataField

  templatePreviewOptions: ->
    chooseNonEmptyViewingAngle: true

  pushPart: (part, previewOptions) ->
    # Put current part on the stack.
    currentPart = @part()
    @partStack.push currentPart if currentPart

    # Set new part as active.
    @part part

    # Replace preview options, if they're present.
    @previewOptions previewOptions if previewOptions

    # Reset force modes.
    @forceShowTemplates false
    @forceShowEditor false

    # Clear hovered template.
    @hoveredTemplate? null

  popPart: ->
    # Get the last part from the stack.
    lastPart = @partStack.pop()

    @part lastPart

  partProperties: ->
    _.values @part().properties

  # Note that we can't name this helper 'template' since that would override Blaze Component template method.
  partTemplate: ->
    @part()?.options.dataLocation()?.template
    
  fullPartTemplate: ->
    return unless embeddedTemplate = @partTemplate()

    # We must fetch the full template that has author data.
    LOI.Character.Part.Template.documents.findOne embeddedTemplate._id

  isOwnPartTemplate: ->
    userId = Meteor.userId()
    return unless template = @fullPartTemplate()
    template.author?._id is userId

  isTemplateEditable: ->
    # The template is editable if it belongs to the user and is not locked to a version.
    @isOwnPartTemplate() and not @partTemplate().version?

  isTemplatePublishable: ->
    # The template is publishable when it has been edited.
    @isTemplateEditable() and not @fullPartTemplate().dataPublished

  canUpgradeTemplate: ->
    return unless dataLocation = @part()?.options.dataLocation
    return unless dataLocation().template
    dataLocation.canUpgradeTemplate LOI.Character.Part.Template.canUpgradeComparator

  canPublishTemplate: ->
    return unless @isTemplatePublishable()
    return unless node = @part()?.options.dataLocation().data()

    # The template can be successfully published only when no unversioned templates are used.
    try
      AMu.Hierarchy.Template.assertNoDraftTemplates node
      
    catch
      return false
      
    true

  publishButtonMainButtonClass: ->
    'main-button' if @canPublishTemplate()

  canRevertTemplate: ->
    # The template can be reverted when it can be published and we have a latest version to revert to.
    @isTemplatePublishable() and @fullPartTemplate().latestVersion

  isEditable: ->
    # User can edit the part if it is not a template or if the template is editable.
    @canCreateNew() and (not @partTemplate() or @isTemplateEditable())

  editableClass: ->
    'editable' if @isEditable()

  canCreateNew: ->
    # Non-admin user can create all parts but shapes.
    return true unless @part() instanceof LOI.Character.Avatar.Parts.Shape

    Retronator.user()?.hasItem Retronator.Store.Items.CatalogKeys.Retronator.Admin

  templatePublished: ->
    template = @fullPartTemplate()
    template.dataPublished

  rootTemplate: ->
    @partTemplate() and not @partStack.length and not @terminal.screens.character.characterId()

  backButtonCallback: ->
    @closePart()

    # Instruct the back button to cancel closing (so it doesn't disappear).
    cancel: true

  closePart: ->
    if @forceShowTemplates()
      # We only need to not show templates in this case.
      @forceShowTemplates false

    else
      # See if we've set any data to this part and delete it if not.
      partDataLocation = @part()?.options.dataLocation
      partNode = partDataLocation()
      partDataLocation.remove() unless partNode

      # If we're on a live template that hasn't been modified, fix the version.
      # Note: we must make sure we have latest version ready since it won't be if we've just published the template.
      if partNode?.template and not partNode.template.version and partNode.template.dataPublished and partNode.template.latestVersion
        partDataLocation.setTemplate partNode.template._id, partNode.template.latestVersion.index

      # Pop this part off the stack.
      @popPart()

      unless @part()
        # There are no more parts to show, so we exit avatar part editor.
        if @terminal.screens.character.characterId()
          # We were editing a character so we return to the character screen.
          @terminal.switchToScreen @terminal.screens.character

        else
          # We were editing a template so we go straight to main menu.
          @terminal.switchToScreen @terminal.screens.mainMenu

  partClass: ->
    return unless part = @part()
    _.kebabCase part.options.type

  ownTemplateClass: ->
    'own-template' if @isOwnPartTemplate()

  propertyClass: ->
    property = @currentData()
    _.kebabCase property.options.name

  avatarPreviewOptions: ->
    _.extend
      rotatable: true
      viewingAngle: @terminal.viewingAngle
    ,
      @previewOptions()

  events: ->
    super(arguments...).concat
      'click .done-button': @onClickDoneButton
      'click .publish-button': @onClickPublishButton
      'click .replace-button': @onClickReplaceButton
      'click .save-as-template-button': @onClickSaveAsTemplateButton
      'click .unlink-template-button': @onClickUnlinkTemplateButton
      'click .modify-template-button': @onClickModifyTemplateButton
      'click .revert-template-button': @onClickRevertTemplateButton
      'click .upgrade-template-button': @onClickUpgradeTemplateButton
      'click .new-part-button': @onClickNewPartButton
      'click .delete-button': @onClickDeleteButton
      'click .template': @onClickTemplate
      'mouseenter .avatar-part': @onMouseEnterAvatarPart
      'mouseleave .avatar-part': @onMouseLeaveAvatarPart

  onClickDoneButton: (event) ->
    @closePart()

  onClickPublishButton: (event) ->
    unless @canPublishTemplate()
      @terminal.showDialog
        message: "You can't publish a template that includes draft templates."
        cancelButtonText: "OK"

      return

    # Publish a new version of this template.
    @part()?.options.dataLocation.publishTemplate()

    @closePart()

  onClickReplaceButton: (event) ->
    @forceShowTemplates true
    @forceShowEditor false
    @hoveredTemplate null

  onClickSaveAsTemplateButton: (event) ->
    @part()?.options.dataLocation.createTemplate()

  onClickUnlinkTemplateButton: (event) ->
    @_applyPartAction 'unlinkTemplate'

  onClickModifyTemplateButton: (event) ->
    # Set the same template without a version.
    templateId = @partTemplate()._id
    @part()?.options.dataLocation.setTemplate templateId

  onClickRevertTemplateButton: (event) ->
    @part()?.options.dataLocation.revertTemplate()

  onClickUpgradeTemplateButton: (event) ->
    @part()?.options.dataLocation.upgradeTemplate LOI.Character.Part.Template.canUpgradeComparator

  onClickNewPartButton: (event) ->
    # Delete current data at this node.
    @part()?.options.dataLocation.clear()

    @forceShowEditor true
    @forceShowTemplates false

  onClickDeleteButton: (event) ->
    # Delete current data at this node.
    @_applyPartAction 'remove'

    # Pop this part off the stack.
    @closePart()

  _applyPartAction: (action) ->
    if part = @part()
      part.options.dataLocation[action]()

      if part.counterpartTemplateParts
        for counterpart in part.counterpartTemplateParts
          counterpart.options.dataLocation[action]()

  onClickTemplate: (event) ->
    template = @currentData()

    if part = @part()
      part.options.dataLocation.setTemplate template._id, template.latestVersion.index

      if template.counterpartTemplates
        for counterpartTemplate in template.counterpartTemplates
          array = part.options.parent
          newPart = array.newPart part.options.type
          newPart.options.dataLocation.setTemplate counterpartTemplate._id, counterpartTemplate.latestVersion.index

    @forceShowTemplates false
    @hoveredTemplate null

  onMouseEnterAvatarPart: (event) ->
    data = @currentData()

    if data instanceof LOI.Character.Part.Template
      template = data

    else if data instanceof LOI.Character.Part
      field = data.options.dataLocation.field()
      return unless field.isTemplate()
      template = field.getTemplate()

    else
      return

    @hoveredTemplate template

  onMouseLeaveAvatarPart: (event) ->
    @hoveredTemplate null
