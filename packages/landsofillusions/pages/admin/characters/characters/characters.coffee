AM = Artificial.Mirage
AMu = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Pages.Admin.Characters.Characters extends AM.Component
  @register 'LandsOfIllusions.Pages.Admin.Characters.Characters'
  
  onCreated: ->
    super arguments...

    # Subscribe to all characters that haven't been retired.
    LOI.Character.allLive.subscribe()
    #LOI.Character.forCurrentUser.subscribe()

    # Subscribe to all character part templates.
    types = LOI.Character.Part.allPartTypeIds()
    LOI.Character.Part.Template.forTypes.subscribe @, types

    @showOnlyStale = new ReactiveField false
    @displayCount = new ReactiveField 10

  charactersCount: ->
    LOI.Character.documents.find().count()

  templatesCount: ->
    LOI.Character.Part.Template.documents.find().count()

  showOnlyStaleCheckedAttribute: ->
    'checked' if @showOnlyStale()

  showOnlyStaleClass: ->
    'show-only-stale' if @showOnlyStale()

  characters: ->
    LOI.Character.documents.fetch {},
      sort:
        'user.displayName': 1
        debugName: 1
      limit: @displayCount()

  characterCanEmbed: ->
    character = @currentData()
    @_characterCanEmbed character

  characterCanUpgrade: ->
    character = @currentData()
    @_characterCanUpgrade character

  _characterCanEmbed: (character) ->
    usedTemplates = @_getUsedTemplates character

    for usedTemplate in usedTemplates
      return true if @_usedTemplateCanEmbed usedTemplate

    false

  _characterCanUpgrade: (character) ->
    usedTemplates = @_getUsedTemplates character

    for usedTemplate in usedTemplates
      return true if @_usedTemplateCanUpgrade usedTemplate

    false

  staleCharacterClass: ->
    character = @currentData()
    'stale' if @_characterCanUpgrade(character) or @_characterCanEmbed(character)

  usedTemplates: ->
    character = @currentData()
    @_getUsedTemplates character

  _getUsedTemplates: (character) ->
    usedTemplates = []

    collectTemplates = (data) =>
      for key, value of data
        if key is 'templateId'
          usedTemplates.push
            id: value

        else if key is 'template'
          usedTemplates.push value

        else if _.isObject value
          collectTemplates value

    collectTemplates character.avatar?.body
    collectTemplates character.avatar?.outfit
    collectTemplates character.behavior

    usedTemplates

  usedTemplate: ->
    usedTemplate = @currentData()
    LOI.Character.Part.Template.documents.findOne usedTemplate.id

  canEmbedUsedTemplateClass: ->
    usedTemplate = @currentData()
    'can-embed' if @_usedTemplateCanEmbed usedTemplate

  canUpgradeUsedTemplateClass: ->
    usedTemplate = @currentData()
    'can-upgrade' if @_usedTemplateCanUpgrade usedTemplate

  _usedTemplateCanEmbed: (usedTemplate) ->
    not usedTemplate.data

  _usedTemplateCanUpgrade: (usedTemplate) ->
    return unless liveTemplate = LOI.Character.Part.Template.documents.findOne usedTemplate.id

    LOI.Character.Part.Template.canUpgradeComparator usedTemplate, liveTemplate

  usedTemplateName: ->
    usedTemplate = @currentData()
    return usedTemplate.name if usedTemplate.name

    return unless liveTemplate = LOI.Character.Part.Template.documents.findOne usedTemplate.id
    liveTemplate.name?.translate().text

  events: ->
    super(arguments...).concat
      'change .show-only-stale-checkbox': @onChangeShowOnlyStaleCheckbox
      'click .embed-all-button': @onClickEmbedAllButton
      'click .upgrade-all-button': @onClickUpgradeAllButton
      'click .embed-button': @onClickEmbedButton
      'click .upgrade-button': @onClickUpgradeButton
      'click .display-more-button': @onClickDisplayMoreButton

  onChangeShowOnlyStaleCheckbox: (event) ->
    @showOnlyStale $(event.target).is(':checked')

  onClickEmbedAllButton: (event) ->
    for character in LOI.Character.documents.fetch() when @_characterCanEmbed character
      @_embedCharacter character

  onClickUpgradeAllButton: (event) ->
    for character in LOI.Character.documents.fetch() when @_characterCanUpgrade character
      @_upgradeCharacter character

  onClickEmbedButton: (event) ->
    character = @currentData()
    @_embedCharacter character

  _embedCharacter: (character) ->
    instance = new LOI.Character.Instance character._id, => character

    for part in [instance.avatar.body, instance.avatar.outfit, instance.behavior.part]
      part.options.dataLocation.embed true

  onClickUpgradeButton: (event) ->
    character = @currentData()
    @_upgradeCharacter character

  _upgradeCharacter: (character) ->
    instance = new LOI.Character.Instance character._id, => character
    comparator = LOI.Character.Part.Template.canUpgradeComparator

    for part in [instance.avatar.body, instance.avatar.outfit, instance.behavior.part]
      part.options.dataLocation.upgrade comparator if part.options.dataLocation.canUpgrade comparator

  onClickDisplayMoreButton: ->
    @displayCount @displayCount() + 100
