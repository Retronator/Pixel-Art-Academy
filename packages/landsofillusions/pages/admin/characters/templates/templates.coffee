AM = Artificial.Mirage
AMu = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Pages.Admin.Characters.Templates extends AM.Component
  @register 'LandsOfIllusions.Pages.Admin.Characters.Templates'
  
  onCreated: ->
    super arguments...

    # Subscribe to all character part templates.
    types = LOI.Character.Part.allPartTypeIds()
    LOI.Character.Part.Template.forTypes.subscribe @, types

    @showOnlyStale = new ReactiveField false
    @showOnlyNotPublished = new ReactiveField false

  showOnlyStaleCheckedAttribute: ->
    'checked' if @showOnlyStale()

  showOnlySNotPublishedCheckedAttribute: ->
    'checked' if @showOnlyNotPublished()

  showOnlyStaleClass: ->
    'show-only-stale' if @showOnlyStale()

  showOnlyNotPublishedClass: ->
    'show-only-not-published' if @showOnlyNotPublished()

  templates: ->
    LOI.Character.Part.Template.documents.fetch {},
      sort:
        type: 1
        'name.translations.best.text': 1

  templateStale: ->
    template = @currentData()
    @_templateStale template

  _templateStale: (template) ->
    usedTemplates = @_getUsedTemplates template

    for usedTemplate in usedTemplates
      return true if @_usedTemplateStale usedTemplate

    false

  staleTemplateClass: ->
    template = @currentData()
    'stale' if @_templateStale template

  notPublishedClass: ->
    template = @currentData()
    'not-published' unless template.dataPublished

  usedTemplates: ->
    template = @currentData()
    @_getUsedTemplates template

  _getUsedTemplates: (template) ->
    usedTemplates = []

    collectTemplates = (data) =>
      for key, value of data
        if key is 'template'
          usedTemplates.push value

        else if _.isObject value
          collectTemplates value

    collectTemplates template.data
    usedTemplates

  usedTemplate: ->
    usedTemplate = @currentData()
    LOI.Character.Part.Template.documents.findOne usedTemplate.id

  staleUsedTemplateClass: ->
    usedTemplate = @currentData()
    'stale' if @_usedTemplateStale usedTemplate

  _usedTemplateStale: (usedTemplate) ->
    return unless liveTemplate = LOI.Character.Part.Template.documents.findOne usedTemplate.id

    LOI.Character.Part.Template.canUpgradeComparator usedTemplate, liveTemplate

  events: ->
    super(arguments...).concat
      'change .show-only-stale-checkbox': @onChangeShowOnlyStaleCheckbox
      'change .show-only-not-published-checkbox': @onChangeShowOnlyNotPublishedCheckbox
      'click .upgrade-all-button': @onClickUpgradeAllButton
      'click .upgrade-button': @onClickUpgradeButton
      'click .publish-button': @onClickPublishButton

  onChangeShowOnlyStaleCheckbox: (event) ->
    @showOnlyStale $(event.target).is(':checked')

  onChangeShowOnlyNotPublishedCheckbox: (event) ->
    @showOnlyNotPublished $(event.target).is(':checked')

  onClickUpgradeAllButton: (event) ->
    for template in LOI.Character.Part.Template.documents.fetch() when @_templateStale template
      @_upgradeTemplate template

  onClickUpgradeButton: (event) ->
    template = @currentData()
    @_upgradeTemplate template

  _upgradeTemplate: (template) ->
    templatePart = new SanFrancisco.C3.Design.TemplatePart template._id
    location = templatePart.part.options.dataLocation

    # Upgrade all templates inside this template.
    location.upgradeTemplates LOI.Character.Part.Template.canUpgradeComparator

    # Publish the upgraded template.
    location.publishTemplate()

  onClickPublishButton: (event) ->
    template = @currentData()

    templatePart = new SanFrancisco.C3.Design.TemplatePart template._id
    templatePart.part.options.dataLocation.publishTemplate()
