LOI = LandsOfIllusions

class LOI.Character.Behavior.Perks extends LOI.Character.Part.Property.Array
  activePerks: ->
    behaviorPart = @options.parentPart

    _.filter @parts(), (part) => part.constructor.satisfiesRequirements behaviorPart
