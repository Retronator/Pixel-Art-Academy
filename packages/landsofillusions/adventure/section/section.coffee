AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Adventure.Section extends LOI.Adventure.Thing
  @scenes: -> throw new AE.NotImplementedException

  @fullName: -> "" # Sections don't need to be named.

  @finished: -> false # Override to set goal state conditions.
  finished: -> @constructor.finished()

  constructor: (@options) ->
    super

    @chapter = @options.chapter

    # React to section becoming active.
    @autorun (computation) =>
      active = @active()
      return unless active?

      if active and @_wasActive is false
        @onStart()

      @_wasActive = active

    @scenes = for sceneClass in @constructor.scenes()
      new sceneClass section: @

  destroy: ->
    super

    scene.destroy() for scene in @scenes

  active: ->
    # Override and add additional logic to create prerequisites for the section being started.
    finished = @finished()

    # Finished can return undefined, which means it is not ready to determine its state.
    return unless finished?

    # By default the section is active until it is finished.
    not finished

  onStart: -> # Override to provide any initialization logic when the section begins.

  ready: ->
    activeWasDetermined = @active()?
    
    # Section is ready when it has determined its active status.
    conditions = _.flattenDeep [
      super
      activeWasDetermined
    ]

    console.log "Section ready?", @id(), conditions if LOI.debug

    _.every conditions
