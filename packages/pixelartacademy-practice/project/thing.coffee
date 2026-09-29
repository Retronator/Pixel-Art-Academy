AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Thing extends PAA.Practice.Thing
  # activeProjectId: ID of the project that is currently actives
  @assetsProviderClass: -> throw new AE.NotImplementedException "Project thing must specify which assets provider class creates its assets."
  
  @visible: -> throw new AE.NotImplementedException "Project thing must specify when the project becomes visible in the portfolio."
  
  @editable: -> throw new AE.NotImplementedException "Project thing must specify when the projects can be added/removed in the portfolio."

  @nameAssetsProviderInstructions: -> "Name your project"

  @assetsProviderNamePlaceholder: -> "Enter project name"

  @defaultAssetsProviderName: -> "Untitled project"

  @newAssetsProviderPlaceholder: -> "Create new project"

  @editAssetsProviderInstructions: -> "Edit project"

  @duplicateAssetsProviderInstructions: -> "Enter the name for the duplicate"

  @deleteAssetsProviderConfirmation: -> "Are you sure you want to delete this project? This cannot be undone."

  @initialize: ->
    super arguments...

    # On the server, create the translated project management texts.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        translationNamespace = @id()
        properties = [
          'nameAssetsProviderInstructions'
          'assetsProviderNamePlaceholder'
          'defaultAssetsProviderName'
          'newAssetsProviderPlaceholder'
          'editAssetsProviderInstructions'
          'duplicateAssetsProviderInstructions'
          'deleteAssetsProviderConfirmation'
        ]

        AB.createTranslation translationNamespace, property, @[property]() for property in properties
  
  @start: ->
    # Make sure the player doesn't have an already active project.
    throw new AE.InvalidOperationException "Profile already has an active project." if @state 'activeProjectId'
    
  @end: ->
    # Make sure the player has an active project.
    projectId = @state 'activeProjectId'
    throw new AE.InvalidOperationException "Profile does not have an active project." unless projectId
    
    # End the project.
    endTime = new Date()
    projectId = PAA.Practice.Project.documents.update projectId,
      $set:
        endTime: endTime
        lastEditTime: endTime
    
    # Remove project ID from profile's game state.
    @state 'activeProjectId', null
    
  @hasProjects: ->
    PAA.Practice.Project.documents.find(
      type: @id()
    ,
      fields:
        _id: 1
    ).count()
  
  constructor: ->
    super arguments...

    # Subscribe to this project's management text translations.
    translationNamespace = @id()
    @_translationSubscription = AB.subscribeNamespace translationNamespace

    @_assetsProviders = {}
    
  destroy: ->
    super arguments...

    @_translationSubscription.stop()
    assetsProvider.destroy() for assetsProvider in @_assetsProviders

  assetsProviders: ->
    projects = PAA.Practice.Project.documents.fetch
      type: @id()
    ,
      fields:
        _id: 1
      sort:
        startTime: 1
    
    for project in projects
      @getAssetsProvider project._id

  activeAssetsProvider: ->
    return unless activeProjectId = @state 'activeProjectId'
    @getAssetsProvider activeProjectId

  getAssetsProvider: (assetsProviderId) ->
    assetsProviderClass = @constructor.assetsProviderClass()
    @_assetsProviders[assetsProviderId] ?= Tracker.nonreactive => new assetsProviderClass @, assetsProviderId
    @_assetsProviders[assetsProviderId]
    
  activateAssetsProvider: (assetsProvider) ->
    @state 'activeProjectId', assetsProvider.id()
  
  canDeactivateAssetsProvider: -> @constructor.editable()

  deactivateAssetsProvider: ->
    @constructor.end()

  createAssetsProvider: (properties = {}) ->
    @constructor.start properties

  duplicateAssetsProvider: (assetsProvider, properties = {}) ->
    project = PAA.Practice.Project.documents.findOne assetsProvider.id()
    throw new AE.ArgumentException "The project to duplicate does not exist." unless project

    project = _.extend {}, project, properties
    project._id = Random.id()
    project.lastEditTime = project.startTime = new Date()
    delete project.endTime
    project.assets = for asset in project.assets
      if asset.bitmapId
        bitmap = LOI.Assets.Bitmap.documents.findOne asset.bitmapId
        bitmap._id = Random.id()
        bitmap.historyPosition = 0
        bitmap.history = []
        bitmap.lastEditTime = project.lastEditTime

        LOI.Assets.Bitmap.documents.insert bitmap
        asset.bitmapId = bitmap._id

      asset

    PAA.Practice.Project.documents.insert project

  deleteAssetsProvider: (assetsProvider) ->
    projectId = assetsProvider.id()
    project = PAA.Practice.Project.documents.findOne projectId
    throw new AE.ArgumentException "The project to delete does not exist." unless project

    # End the project first if it is currently active.
    @constructor.end() if @constructor.state('activeProjectId') is projectId

    PAA.Practice.Project.documents.remove projectId

    # Remove bitmap documents that are no longer used by another project.
    for asset in project.assets
      if asset.bitmapId
        LOI.Assets.Bitmap.removeFully asset.bitmapId

    delete @_assetsProviders[projectId]
    Tracker.afterFlush => assetsProvider.destroy?()
    
  nameAssetsProviderInstructions: -> AB.translate(@_translationSubscription, 'nameAssetsProviderInstructions').text
  nameAssetsProviderInstructionsTranslation: -> AB.translation @_translationSubscription, 'nameAssetsProviderInstructions'

  assetsProviderNamePlaceholder: -> AB.translate(@_translationSubscription, 'assetsProviderNamePlaceholder').text
  assetsProviderNamePlaceholderTranslation: -> AB.translation @_translationSubscription, 'assetsProviderNamePlaceholder'

  defaultAssetsProviderName: -> AB.translate(@_translationSubscription, 'defaultAssetsProviderName').text
  defaultAssetsProviderNameTranslation: -> AB.translation @_translationSubscription, 'defaultAssetsProviderName'

  newAssetsProviderPlaceholder: -> AB.translate(@_translationSubscription, 'newAssetsProviderPlaceholder').text
  newAssetsProviderPlaceholderTranslation: -> AB.translation @_translationSubscription, 'newAssetsProviderPlaceholder'

  editAssetsProviderInstructions: -> AB.translate(@_translationSubscription, 'editAssetsProviderInstructions').text
  editAssetsProviderInstructionsTranslation: -> AB.translation @_translationSubscription, 'editAssetsProviderInstructions'

  duplicateAssetsProviderInstructions: -> AB.translate(@_translationSubscription, 'duplicateAssetsProviderInstructions').text
  duplicateAssetsProviderInstructionsTranslation: -> AB.translation @_translationSubscription, 'duplicateAssetsProviderInstructions'

  deleteAssetsProviderConfirmation: -> AB.translate(@_translationSubscription, 'deleteAssetsProviderConfirmation').text
  deleteAssetsProviderConfirmationTranslation: -> AB.translation @_translationSubscription, 'deleteAssetsProviderConfirmation'
  
  assetsProviderLabelCategory: -> @fullName()
