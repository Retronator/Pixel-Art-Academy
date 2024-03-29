AB = Artificial.Babel
AM = Artificial.Mirage
AMu = Artificial.Mummification
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.MainMenu extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.MainMenu'

  constructor: (@terminal) ->
    super arguments...

    @templatesTypeFilter = new ReactiveField null

  onCreated: ->
    super arguments...

    @characters = new ComputedField =>
      return unless characters = Retronator.user()?.characters

      characters = for character in characters
        LOI.Character.documents.findOne character._id

      _.pull characters, undefined

      for character in characters
        character.translatedName = AB.translate(character.avatar.fullName).text

        # Create temporary hierarchy locations.
        bodyLocation = new AMu.Hierarchy.Location
          rootField: AMu.Hierarchy.create
            type: LOI.Character.Part.Types.Avatar.Body.options.type
            templateClass: LOI.Character.Part.Template
            load: => character.avatar.body

        outfitLocation = new AMu.Hierarchy.Location
          rootField: AMu.Hierarchy.create
            type: LOI.Character.Part.Types.Avatar.Outfit.options.type
            templateClass: LOI.Character.Part.Template
            load: => character.avatar.outfit

        comparator = LOI.Character.Part.Template.canUpgradeComparator
        character.canUpgrade = bodyLocation.canUpgrade(comparator) or outfitLocation.canUpgrade(comparator)

      _.sortBy characters, 'translatedName'

    @templates = new ComputedField =>
      type = @templatesTypeFilter() or /Avatar/

      # Get all the templates this user is author of.
      templates = LOI.Character.Part.Template.documents.fetch
        'author._id': Meteor.userId()
        type: type

      for template in templates
        template.translatedName = AB.translate(template.name).text

      # Schedule repositioning of the scroll after the list has updated.
      Tracker.afterFlush =>
        Tracker.autorun (computation) =>
          return unless @isRendered()
          computation.stop()

          @$('.templates .document-selection')?.scrollTop @_templatesDocumentSelectionScrollTop

      _.sortBy templates, 'translatedName'

    partTypes = LOI.Character.Part.allAvatarPartTypeIds()

    templateCategories = for partType in partTypes
      type: partType
      name: _.last partType.split('.')

    @templateCategories = _.sortBy templateCategories, 'name'

  templateCategorySelectedAttribute: ->
    option = @currentData()

    'selected' if option.type is @templatesTypeFilter()

  templateVersion: ->
    template = @currentData()

    if template.dataPublished
      # We're showing the last published version.
      template.latestVersion.index + 1

    else
      # We're editing the next version.
      versionsCount = template.versions?.length or 0
      versionsCount + 1

  events: ->
    super(arguments...).concat
      'click .character-selection-button': @onClickCharacterSelectionButton
      'click .new-character-button': @onClickNewCharacterButton
      'change .category-selection': @onChangeCategorySelection
      'click .template-selection-button': @onClickTemplateSelectionButton
      'click .new-template-button': @onClickNewTemplateButton
      'scroll .templates .document-selection': @onScrollTemplatesDocumentSelection

  onClickCharacterSelectionButton: (event) ->
    character = @currentData()

    selectCharacter = =>
      @terminal.screens.character.setCharacterId character._id
      @terminal.switchToScreen @terminal.screens.character

    # Inform the user if design has been revoked.
    if character.activated and not character.designApproved
      @terminal.showDialog
        message: "Agent's design has been revoked. Please redesign the body and outfit with currently available parts."
        confirmButtonText: "OK"
        confirmButtonClass: 'positive-button'
        confirmAction: =>
          selectCharacter()

    else
      selectCharacter()

  onClickNewCharacterButton: (event) ->
    LOI.Character.insert (error, characterId) =>
      if error
        console.error error
        return

      @terminal.screens.character.setCharacterId characterId
      @terminal.switchToScreen @terminal.screens.character

  onChangeCategorySelection: (event) ->
    @templatesTypeFilter $(event.target).val()

  onClickTemplateSelectionButton: (event) ->
    template = @currentData()

    @_openTemplate template._id

  onClickNewTemplateButton: (event) ->
    data = fields: {}
    metaData = type: @templatesTypeFilter()

    LOI.Character.Part.Template.insert data, metaData, (error, templateId) =>
      if error
        console.error error
        return

      @_openTemplate templateId

  _openTemplate: (templateId) ->
    templatePart = new C3.Design.TemplatePart templateId

    @terminal.screens.avatarPart.pushPart templatePart.part, templatePart.part
    @terminal.switchToScreen @terminal.screens.avatarPart

    # Clean up any previous character selection so the interface knows we're editing a template.
    @terminal.screens.character.setCharacterId null

  onScrollTemplatesDocumentSelection: (event) ->
    @_templatesDocumentSelectionScrollTop = event.target.scrollTop
