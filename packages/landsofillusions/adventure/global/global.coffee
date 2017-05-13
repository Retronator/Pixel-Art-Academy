AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Adventure.Global extends LOI.Adventure.Thing
  @fullName: -> null # Globals don't need to be named.

  @timelineId: -> # Override to set a default timeline for scenes.
  timelineId: -> @constructor.timelineId()

  @scenes: -> # Override to provide global scenes.

  constructor: ->
    super

    @_scenes = for sceneClass in @constructor.scenes()
      new sceneClass parent: @

  destroy: ->
    super

    scene.destroy() for scene in @scenes

  scenes: ->
    @_scenes
