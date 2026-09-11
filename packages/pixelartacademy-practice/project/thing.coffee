AE = Artificial.Everywhere
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Thing extends PAA.Practice.Thing
  # activeProjectId: ID of the project that is currently actives
  @assetsProviderClass: -> throw new AE.NotImplementedException "Project thing must specify which assets provider class creates its assets."
  
  @visible: -> throw new AE.NotImplementedException "Project thing must specify when the project becomes visible in the portfolio."
  
  @editable: -> throw new AE.NotImplementedException "Project thing must specify when the projects can be added/removed in the portfolio."
  
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

    @_assetsProviders = {}
    
  destroy: ->
    super arguments...

    assetsProvider.destroy() for assetsProvider in @_assetsProviders

  assetsProviders: ->
    projects = PAA.Practice.Project.documents.fetch
      type: @id()
    ,
      fields:
        _id: 1
    
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

  createNewAssetsProvider: ->
    @constructor.start()
