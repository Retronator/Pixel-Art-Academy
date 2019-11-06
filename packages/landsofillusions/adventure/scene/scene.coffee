AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Adventure.Scene extends LOI.Adventure.Thing
  @location: -> throw new AE.NotImplementedException
  location: -> @constructor.location()

  @timelineId: -> # Override to set a specific timeline
  timelineId: ->
    # By default we use the timeline of the parent.
    @constructor.timelineId() or @options?.parent.timelineId()

  @fullName: -> null # Scenes don't need to be named.

  constructor: ->
    super arguments...

    @section = @options?.parent if @options?.parent instanceof LOI.Adventure.Section

    @_active = false

    @_sceneActiveAutorun = Tracker.autorun (computation) =>
      return unless LOI.adventureInitialized()
      return unless activeScenes = LOI.adventure.activeScenes()

      wasActive = @_active
      @_active = @ in activeScenes

      if not wasActive and @_active
        Tracker.nonreactive => @onActivated()

      else if wasActive and not @_active
        Tracker.nonreactive => @onDeactivated()

  destroy: ->
    super arguments...

    @_sceneActiveAutorun.stop()

  onActivated: -> # Override to apply logic when the scene becomes active.
  onDeactivated: -> # Override to apply logic when the scene ends being active.
