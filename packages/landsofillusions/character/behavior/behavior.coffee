AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Character.Behavior
  constructor: (@character) ->
    # Create the behavior hierarchy.
    behaviorDataField = AM.Hierarchy.create
      templateClass: LOI.Character.Part.Template
      type: LOI.Character.Part.Types.Outfit.options.type
      load: => @character.document()?.behavior
      save: (address, value) =>
        LOI.Character.updateBehavior @character.id, address, value

    @part = LOI.Character.Part.Types.Behavior.create
      dataLocation: new AM.Hierarchy.Location
        rootField: behaviorDataField

    @personality = new @constructor.Personality @
    @focalPoints = new @constructor.FocalPoints @

  destroy: ->
    @personality.destroy()
