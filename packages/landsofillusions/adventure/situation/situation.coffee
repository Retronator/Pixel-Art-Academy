LOI = LandsOfIllusions

class LOI.Adventure.Situation
  constructor: (@options) ->
    {location, timelineId, context} = @options

    console.log "%cCreating situation for", 'background: plum', location.id(), timelineId if LOI.debug

    CircumstanceTypes = @constructor.Circumstance.Types

    @circumstanceNames =
      things: CircumstanceTypes.Array
      exits: CircumstanceTypes.Map
      description: CircumstanceTypes.Array
      illustration: CircumstanceTypes.Map
      postscript: CircumstanceTypes.Array

    # Create all the circumstances as properties of the situation.
    for circumstanceName, circumstanceType of @circumstanceNames
      @[circumstanceName] = new @constructor.Circumstance circumstanceType

    # Situation starts with location.
    @_applyScene location

    # Now apply all current scene modifications that apply to this time and place.
    scenes = []

    for scene in LOI.adventure.currentScenes()
      # We compare IDs since we can get in a class or an instance.
      locationClass = _.thingClass location
      sceneLocationClass = _.thingClass scene.location()
      validLocation = not sceneLocationClass or (locationClass is sceneLocationClass) or (locationClass in sceneLocationClass)

      sceneTimelineId = scene.timelineId()
      validTimeline = (not sceneTimelineId) or (not timelineId) or (timelineId is sceneTimelineId) or (timelineId in sceneTimelineId)

      scenes.push scene if validLocation and validTimeline

    console.log "Filtered current scenes", LOI.adventure.currentScenes(), "to relevant ones", scenes if LOI.debug

    @_applyScene scene for scene in scenes

    # Finally apply the context, which can override other things.
    @_applyScene context if context

    @exitsById = new ComputedField =>
      # Generate a unique set of exit classes from all directions (some directions might lead to
      # same location) so we don't have multiple avatar objects for the same location.
      exitClasses = _.uniq _.values @exits()
      exitClasses = _.without exitClasses, null

      exitsById = {}
      exitsById[exitClass.id()] = exitClass for exitClass in exitClasses

      exitsById

  _applyScene: (scene) ->
    console.log "%cApplying scene", 'background: thistle', scene.id() if LOI.debug
    
    for circumstanceName of @circumstanceNames
      circumstance = @[circumstanceName]

      if addValues = scene[circumstanceName]?()
        circumstance.add addValues
        console.log "Added", addValues, "to circumstance", circumstanceName if LOI.debug

      if removeValues = scene["remove#{_.upperFirst circumstanceName}"]?()
        circumstance.remove removeValues
        console.log "Removed", removeValues, "from circumstance", circumstanceName if LOI.debug

      if clear = scene["clear#{_.upperFirst circumstanceName}"]?()
        circumstance.clear()
        console.log "Cleared circumstance", circumstanceName if LOI.debug

      if overrideValues = scene["override#{_.upperFirst circumstanceName}"]?()
        circumstance.override overrideValues
        console.log "Overrode with", addValues, "in circumstance", circumstanceName if LOI.debug

      console.log "new value of circumstance", circumstanceName, "is", circumstance() if LOI.debug
