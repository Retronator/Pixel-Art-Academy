AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Adventure.Section extends LOI.Adventure.Thing
  @scenes: -> throw new AE.NotImplementedException

  @fullName: -> null # Sections don't need to be named.

  @finished: -> false # Override to set goal state conditions.
  finished: -> @constructor.finished()

  @timelineId: -> # Override to set a default timeline for scenes.
  timelineId: ->
    # By default we use the timeline of the chapter.
    @constructor.timelineId() or @options?.parent?.timelineId()
  
  constructor: (@options) ->
    super

    @chapter = @options.parent if @options?.parent instanceof LOI.Adventure.Chapter

    @_scenes = for sceneClass in @constructor.scenes()
      new sceneClass parent: @

  destroy: ->
    super

    scene.destroy() for scene in @scenes

  scenes: ->
    @_scenes

  active: ->
    @_activeUntilFinished()

  _activeUntilFinished: ->
    # Override and add additional logic to create prerequisites for the section being started.
    finished = @finished()

    # Finished can return undefined, which means it is not ready to determine its state.
    return unless finished?

    # By default the section is active until it is finished.
    not finished

  requireFinishedSections: (sections) ->
    # Allow for passing of a single section.
    sections = [sections] unless _.isArray sections

    # See if sections are finished.
    sectionsFinished = (section.finished() for section in sections)

    # If any of the sections returns undefined, we're not yet ready to determine our active state.
    return if sectionsFinished.indexOf(undefined) > -1

    # We're not active if all required sections are not finished.
    return false unless _.every sectionsFinished

    # Section has the prerequisites. Now check that it hasn't finished yet.
    @_activeUntilFinished()

  ready: ->
    activeWasDetermined = @active()?
    
    # Section is ready when it has determined its active status.
    conditions = _.flattenDeep [
      super
      activeWasDetermined
    ]

    console.log "Section ready?", @id(), conditions if LOI.debug

    _.every conditions

  reset: ->
    @state.set {}
