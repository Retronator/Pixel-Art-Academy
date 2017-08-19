LOI = LandsOfIllusions

class LOI.Character.Behavior.Perks extends LOI.Character.Part.Property.Array
  activePerks: ->
    _.filter @parts(), (part) => part.satisfiesRequirements()
