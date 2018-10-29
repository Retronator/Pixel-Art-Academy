LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk.Teammate extends LOI.Character.Behavior.Perk
  @register 'Teammate'
  
  @displayName: "Teammate"
  @description: "You like to make the whole more than the sum of its parts."
  @requirements: "High Cooperation score."
  @effects: """
        Can work on multiple group projects at the same time.
        Always have to help friends.
      """

  @satisfiesRequirements: (behaviorPart) ->
    super arguments...

    factorPowers = behaviorPart.properties.personality.part.factorPowers()
    cooperationScore = factorPowers[2].positive
    cooperationScore >= LOI.Character.Behavior.Perk.factorPowerCutoff
