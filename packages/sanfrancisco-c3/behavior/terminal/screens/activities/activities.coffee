AM = Artificial.Mirage
AMu = Artificial.Mummification
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Activity = LOI.Character.Behavior.Activity

class C3.Behavior.Terminal.Activities extends AM.Component
  @register 'SanFrancisco.C3.Behavior.Terminal.Activities'

  constructor: (@terminal) ->
    super arguments...

    @property = new ReactiveField null

  onCreated: ->
    super arguments...

    # We use this when the user wants to choose a different template (and templates wouldn't be shown by default).
    @forceShowTemplates = new ReactiveField false

    # We use this when the user wants to customize the options.
    @forceShowEditor = new ReactiveField false

    # Get the activities part from the character.
    @autorun (computation) =>
      behaviorPart = @terminal.screens.character.character()?.behavior.part
      activitiesProperty = behaviorPart.properties.activities

      @property activitiesProperty

    @hasCustomData = new ComputedField =>
      @property()?.options.dataLocation()?.data()

    @showTemplates = new ComputedField =>
      return true if @forceShowTemplates()
      return false if @forceShowEditor()

      # We default to showing available templates if the part hasn't been set yet.
      not @hasCustomData()

    # Subscribe to activities templates.
    LOI.Character.Part.Template.forType.subscribe @, LOI.Character.Part.Types.Behavior.options.properties.activities.options.templateType

    @templateNameInput = new LOI.Components.TranslationInput
      placeholderText: => @translation "Name the template"

    @templateDescriptionInput = new LOI.Components.TranslationInput
      placeholderText: => @translation "Describe the activities selection"

  renderTemplateNameInput: ->
    @templateNameInput.renderComponent @currentComponent()

  renderTemplateDescriptionInput: ->
    @templateDescriptionInput.renderComponent @currentComponent()

  templates: ->
    templates = LOI.Character.Part.Template.documents.find(
      type: LOI.Character.Part.Types.Behavior.options.properties.activities.options.templateType
    ).fetch()

    # We sort activity templates by number of hours dedicated to drawing.
    _.sortBy templates, (template) =>
      # Get the key of the drawing activity.
      fieldsKey = _.findKey template.data.fields, (field) => field.node.fields.key.value is Activity.Keys.Drawing

      # Return hours per week value.
      template.data.fields[fieldsKey].node.fields.hoursPerWeek.value

  templateProperty: ->
    template = @currentData()
    property = @property()

    dataField = AMu.Hierarchy.create
      templateClass: LOI.Character.Part.Template
      load: => node: template.latestVersion.data

    property.create
      dataLocation: new AMu.Hierarchy.Location
        rootField: dataField
      template: template

  # Note that we can't name this helper 'template' since that would override Blaze Component template method.
  propertyTemplate: ->
    @property()?.options.dataLocation()?.template

  fullPropertyTemplate: ->
    return unless embeddedTemplate = @propertyTemplate()

    # We must fetch the full template that has author data.
    LOI.Character.Part.Template.documents.findOne embeddedTemplate._id

  isOwnPropertyTemplate: ->
    userId = Meteor.userId()
    return unless template = @fullPropertyTemplate()
    template.author?._id is userId

  isTemplateEditable: ->
    # The template is editable if it belongs to the user and is not locked to a version.
    @isOwnPropertyTemplate() and not @ropertyTemplate().version?

  isTemplatePublishable: ->
    # The template is publishable when it has been edited.
    @isTemplateEditable() and not @fullPropertyTemplate().dataPublished

  canUpgradeTemplate: ->
    return unless dataLocation = @property()?.options.dataLocation
    return unless dataLocation().template
    dataLocation.canUpgradeTemplate LOI.Character.Part.Template.canUpgradeComparator

  canPublishTemplate: ->
    return unless @isTemplatePublishable()
    return unless node = @property()?.options.dataLocation().data()

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
    @isTemplatePublishable() and @fullPropertyTemplate().latestVersion

  isEditable: ->
    # We can edit the property if it's not using a template, or if the template is editable.
    not @propertyTemplate() or @isTemplateEditable()

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

  activities: ->
    # Start with the default activities.
    activities =
      "#{Activity.Keys.Sleep}":
        nameEditable: false
        hoursPerWeek: 0

      "#{Activity.Keys.Job}":
        nameEditable: false
        hoursPerWeek: 0

      "#{Activity.Keys.School}":
        nameEditable: false
        hoursPerWeek: 0

      "#{Activity.Keys.Drawing}":
        nameEditable: false
        hoursPerWeek: 0

    # Add all character's focal points.
    for activityPart in @property().parts()
      activityKey = activityPart.properties.key.options.dataLocation()
      activityHoursPerWeek = activityPart.properties.hoursPerWeek.options.dataLocation()

      unless activities[activityKey]
        activities[activityKey] = nameEditable: true

      activities[activityKey].part = activityPart
      activities[activityKey].hoursPerWeek = activityHoursPerWeek

    # Return an array.
    for activityName, activity of activities
      _.extend {}, activity, key: activityName

  events: ->
    super(arguments...).concat
      'click .done-button': @onClickDoneButton
      'click .replace-button': @onClickReplaceButton
      'click .save-as-template-button': @onClickSaveAsTemplateButton
      'click .unlink-template-button': @onClickUnlinkTemplateButton
      'click .modify-template-button': @onClickModifyTemplateButton
      'click .revert-template-button': @onClickRevertTemplateButton
      'click .upgrade-template-button': @onClickUpgradeTemplateButton
      'click .custom-activities-button': @onClickCustomActivitiesButton
      'click .delete-button': @onClickDeleteButton
      'click .template': @onClickTemplate
      'change .new-activity': @onChangeNewActivity

  onClickDoneButton: (event) ->
    @closeScreen()

  onClickReplaceButton: (event) ->
    @forceShowTemplates true
    @forceShowEditor false

    @$('.main-content').scrollTop(0)

  onClickSaveAsTemplateButton: (event) ->
    @property()?.options.dataLocation.createTemplate()

  onClickUnlinkTemplateButton: (event) ->
    @property()?.options.dataLocation.unlinkTemplate()

  onClickModifyTemplateButton: (event) ->
    # Set the same template without a version.
    templateId = @propertyTemplate()._id
    @property()?.options.dataLocation.setTemplate templateId

  onClickRevertTemplateButton: (event) ->
    @property()?.options.dataLocation.revertTemplate()

  onClickUpgradeTemplateButton: (event) ->
    @property()?.options.dataLocation.upgradeTemplate LOI.Character.Part.Template.canUpgradeComparator

  onClickCustomActivitiesButton: (event) ->
    # Delete current data at this node.
    @property()?.options.dataLocation.clear()

    @forceShowEditor true
    @forceShowTemplates false

  onClickDeleteButton: (event) ->
    # Delete current data at this node.
    @property()?.options.dataLocation.remove()

    # Return to previous screen.
    @closeScreen()

  onClickTemplate: (event) ->
    template = @currentData()

    @property()?.options.dataLocation.setTemplate template._id, template.latestVersion.index

    @forceShowTemplates false

    @$('.main-content').scrollTop(0)

  onChangeNewActivity: (event) ->
    $input = $(event.target)
    name = $input.val()
    return unless name.length

    # Clear input for next entry.
    $input.val('')

    activityType = LOI.Character.Part.Types.Behavior.Activity.options.type
    newPart = @property().newPart activityType

    newPart.options.dataLocation
      key: name
      hoursPerWeek: 0

  # Components

  class @ActivityHoursPerWeek extends AM.DataInputComponent
    @register 'SanFrancisco.C3.Behavior.Terminal.Character.ActivityHoursPerWeek'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Number
      @placeholder = 0
      @customAttributes =
        min: 0
        step: 1

    load: ->
      activityInfo = @data()
      activityInfo.hoursPerWeek

    save: (value) ->
      activityInfo = @data()

      if activityInfo.part
        part = activityInfo.part
        part.properties.hoursPerWeek.options.dataLocation value * @_saveFactor()

      else
        activitiesComponent = @ancestorComponentOfType C3.Behavior.Terminal.Activities

        activityType = LOI.Character.Part.Types.Behavior.Activity.options.type
        newPart = activitiesComponent.property().newPart activityType

        newPart.options.dataLocation
          key: activityInfo.key
          hoursPerWeek: value * @_saveFactor()

    _saveFactor: ->
      1

  class @ActivityHoursPerDay extends @ActivityHoursPerWeek
    @register 'SanFrancisco.C3.Behavior.Terminal.Character.ActivityHoursPerDay'

    load: ->
      activityInfo = @data()
      Math.round(activityInfo.hoursPerWeek / 0.7) / 10

    _saveFactor: ->
      7

  class @ActivityName extends AM.DataInputComponent
    @register 'SanFrancisco.C3.Behavior.Terminal.Character.ActivityName'

    load: ->
      activityInfo = @data()
      activityInfo.key

      # TODO: Get translation for key.

    save: (value) ->
      activityInfo = @data()

      if value.length
        # Update focal point name.
        activityInfo.part.properties.key.options.dataLocation value

      else
        # Delete focal point.
        activityInfo.part.options.dataLocation.remove()
