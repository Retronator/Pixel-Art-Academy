AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Adventure.Section extends LOI.Adventure.Thing
  @scenes: -> throw new AE.NotImplementedException

  @fullName: -> null # Sections don't need to be named.

  @started: -> false # Override to set start state conditions.
  started: -> @constructor.started()

  @finished: -> false # Override to set goal state conditions.
  finished: -> @constructor.finished()

  @timelineId: -> # Override to set a default timeline for scenes.
  timelineId: ->
    # By default we use the timeline of the chapter.
    @constructor.timelineId() or @options?.parent?.timelineId()

  @requireFinishedSections: (sections) ->
    # Allow for passing of a single section.
    sections = [sections] unless _.isArray sections

    # See if sections are finished.
    sectionsFinished = (section.finished() for section in sections)

    # If any of the sections returns undefined, we're not yet ready to determine our active state.
    return if undefined in sectionsFinished

    # We're not active unless all required sections are finished.
    _.every sectionsFinished

  constructor: (@options) ->
    super

    @chapter = @options.parent if @options?.parent instanceof LOI.Adventure.Chapter

    # Cached field to minimize reactivity.
    @_active = new ComputedField =>
      @active()
    ,
      true

    @scenes = new ReactiveField []

    @autorun (computation) =>
      # Create scenes JIT when section becomes active.
      active = @_active()

      # Destroy previous set of scenes.
      Tracker.nonreactive =>
        console.log "Destroyed scenes for", @id() if LOI.debug and @scenes().length
        scene.destroy() for scene in @scenes()

        if active
          scenes = for sceneClass in @constructor.scenes()
            new sceneClass parent: @

          console.log "Created scenes for", @id() if LOI.debug

        else
          scenes = []

        # Set the new scenes.
        @scenes scenes

  destroy: ->
    super

    scene.destroy() for scene in @scenes()

  # Because active relies on started and finished, which can be set on the object, not just on the class, we can only
  # allow active to be defined as an object method. We can think of active as the current state of the section object,
  # whereas started and finished are more of a general condition, usually set on the class, if possible.
  active: ->
    # By default the section is active after started condition is met and ends when finished condition is met.
    # Note that if any of these functions returns undefined, the result of the and operation is also undefined.
    @_activeAfterStarted() and @_activeUntilFinished()

  _activeAfterStarted: ->
    started = @started()

    # Started can return undefined, which means it is not ready to determine its state.
    return unless started?

    started

  _activeUntilFinished: ->
    finished = @finished()

    # Finished can return undefined, which means it is not ready to determine its state.
    return unless finished?

    not finished

  requireFinishedSections: (sections) -> @constructor.requireFinishedSections sections

  ready: ->
    activeWasDetermined = @active()?
    
    # Section is ready when it has determined its active status.
    conditions = _.flattenDeep [
      super
      activeWasDetermined
    ]

    console.log "Section ready?", @id(), conditions if LOI.debug

    _.every conditions
