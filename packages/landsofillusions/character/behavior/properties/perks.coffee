LOI = LandsOfIllusions

class LOI.Character.Behavior.Perks extends LOI.Character.Part.Property.Array
  activePerks: ->
    behaviorPart = @options.parent

    _.filter @parts(), (part) => part.constructor.satisfiesRequirements behaviorPart
