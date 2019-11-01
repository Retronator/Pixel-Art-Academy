LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk.Socializer extends LOI.Character.Behavior.Perk
  @register 'Socializer'
  
  @displayName: "Socializer"
  @description: "People are your energy source and you can't pass an opportunity to hang out."
  @requirements: "High Energy score."
  @effects: """
        Always attends social events.
        More available friend connections.
      """

  @satisfiesRequirements: (behaviorPart) ->
    super arguments...

    factorPowers = behaviorPart.properties.personality.part.factorPowers()
    energyScore = factorPowers[1].positive
    energyScore >= LOI.Character.Behavior.Perk.factorPowerCutoff
