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
