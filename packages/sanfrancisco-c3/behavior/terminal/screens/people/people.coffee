AM = Artificial.Mirage
AMu = Artificial.Mummification
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Person = LOI.Character.Behavior.Person

class C3.Behavior.Terminal.People extends AM.Component
  @register 'SanFrancisco.C3.Behavior.Terminal.People'

  @relationshipStrengthOptions = [
    value: 1
    name: "Monthly"
  ,
    value: 2
    name: "Weekly"
  ,
    value: 3
    name: "Daily"
  ]

  @artSupportOptions = [
    value: -2
    name: "Resentful"
  ,
    value: -1
    name: "Unsupportive"
  ,
    value: 0
    name: "Neutral"
  ,
    value: 1
    name: "Supportive"
  ,
    value: 2
    name: "Sponsor"
  ]

  constructor: (@terminal) ->
    super arguments...

    @property = new ReactiveField null

  onCreated: ->
    super arguments...

    # We use this when the user wants to choose a different template (and templates wouldn't be shown by default).
    @forceShowTemplates = new ReactiveField false

    # We use this when the user wants to customize the options.
    @forceShowEditor = new ReactiveField false

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
    ,
      sort:
        'name.translations.best.text': 1

  templateProperty: ->
    template = @currentData()
    property = @property()

    dataField = AMu.Hierarchy.create
      templateClass: LOI.Character.Part.Template
      load: => template

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
      @terminal.switchToScreen @terminal.screens.environment

  people: ->
    @property()?.parts()

  relationshipType: ->
    person = @currentData()

    _.lowerCase person.properties.relationshipType.options.dataLocation()

  relationshipStrength: ->
    person = @currentData()
    value = person.properties.relationshipStrength.options.dataLocation()

    options = C3.Behavior.Terminal.People.relationshipStrengthOptions
    _.find(options, (option) -> option.value is value).name

  livingProximity: ->
    person = @currentData()

    _.upperFirst _.lowerCase person.properties.livingProximity.options.dataLocation()

  artSupport: ->
    person = @currentData()
    value = person.properties.artSupport.options.dataLocation()

    options = C3.Behavior.Terminal.People.artSupportOptions
    _.find(options, (option) -> option.value is value).name

  events: ->
    super(arguments...).concat
      'click .done-button': @onClickDoneButton
      'click .replace-button': @onClickReplaceButton
      'click .save-as-template-button': @onClickSaveAsTemplateButton
      'click .unlink-template-button': @onClickUnlinkTemplateButton
      'click .modify-template-button': @onClickModifyTemplateButton
      'click .revert-template-button': @onClickRevertTemplateButton
      'click .upgrade-template-button': @onClickUpgradeTemplateButton
      'click .custom-people': @onClickCustomPeople
      'click .delete-button': @onClickDeleteButton
      'click .template': @onClickTemplate
      'click .add-person-button': @onClickAddPersonButton

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

  onClickCustomPeople: (event) ->
    # Delete current data at this node.
    @property()?.options.dataLocation.clear()

    @forceShowEditor true
    @forceShowTemplates false

  onClickDeleteButton: (event) ->
    # Delete current data at this node.
    @property()?.options.dataLocation.remove()

    @closeScreen()

  onClickTemplate: (event) ->
    template = @currentData()

    @property()?.options.dataLocation.setTemplate template._id, template.latestVersion.index

    @forceShowTemplates false

    @$('.main-content').scrollTop(0)

  onClickAddPersonButton: (event) ->
    personType = LOI.Character.Part.Types.Behavior.Environment.Person.options.type
    newPart = @property().newPart personType
    newPart.options.dataLocation {}

  # Components

  class @EnumerationInputComponent extends AM.DataInputComponent
    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    options: ->
      if @load()
        options = []

      else
        options = [
          value: null
          name: ''
        ]

      for value, name of @enumeration
        name = _.upperFirst _.lowerCase name
        options.push {value, name}

      options

    load: ->
      dataLocation = @_dataLocation()
      dataLocation()

    save: (value) ->
      dataLocation = @_dataLocation()
      dataLocation value

    _dataLocation: ->
      person = @data()
      person.properties[@property].options.dataLocation

  class @IntegerEnumerationInputComponent extends AM.DataInputComponent
    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    options: (options) ->
      unless @load()
        options = [
          value: null
          name: ''
        ,
          options...
        ]

      options

    load: ->
      dataLocation = @_dataLocation()
      dataLocation()

    save: (value) ->
      dataLocation = @_dataLocation()
      dataLocation parseInt value

    _dataLocation: ->
      person = @data()
      person.properties[@property].options.dataLocation

  class @RelationshipType extends @EnumerationInputComponent
    @register 'SanFrancisco.C3.Behavior.Terminal.People.RelationshipType'

    constructor: ->
      super arguments...

      @enumeration = LOI.Character.Behavior.Environment.People.RelationshipType
      @property = 'relationshipType'

  class @RelationshipStrength extends @IntegerEnumerationInputComponent
    @register 'SanFrancisco.C3.Behavior.Terminal.People.RelationshipStrength'

    constructor: ->
      super arguments...

      @property = 'relationshipStrength'

    options: ->
      super C3.Behavior.Terminal.People.relationshipStrengthOptions

  class @LivingProximity extends @EnumerationInputComponent
    @register 'SanFrancisco.C3.Behavior.Terminal.People.LivingProximity'

    constructor: ->
      super arguments...

      @enumeration = LOI.Character.Behavior.Environment.People.LivingProximity
      @property = 'livingProximity'

  class @ArtSupport extends @IntegerEnumerationInputComponent
    @register 'SanFrancisco.C3.Behavior.Terminal.People.ArtSupport'

    constructor: ->
      super arguments...

      @property = 'artSupport'

    options: ->
      super C3.Behavior.Terminal.People.artSupportOptions

  class @DoesArt extends AM.DataInputComponent
    @register 'SanFrancisco.C3.Behavior.Terminal.People.DoesArt'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Checkbox

    onCreated: ->
      super arguments...

      @people = @ancestorComponentOfType C3.Behavior.Terminal.People

    customAttributes: ->
      disabled: true unless @people.isEditable()

    load: ->
      dataLocation = @_dataLocation()
      dataLocation()

    save: (value) ->
      dataLocation = @_dataLocation()
      dataLocation value

    _dataLocation: ->
      person = @data()
      person.properties.doesArt.options.dataLocation

  class @Joins extends AM.DataInputComponent
    @register 'SanFrancisco.C3.Behavior.Terminal.People.Joins'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Checkbox

    onCreated: ->
      super arguments...

      @people = @ancestorComponentOfType C3.Behavior.Terminal.People

    customAttributes: ->
      disabled: true unless @people.isEditable()

    load: ->
      dataLocation = @_dataLocation()
      dataLocation()

    save: (value) ->
      dataLocation = @_dataLocation()
      dataLocation value

    _dataLocation: ->
      person = @data()
      person.properties.joins.options.dataLocation
