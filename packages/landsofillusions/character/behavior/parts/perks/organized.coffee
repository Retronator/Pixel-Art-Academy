LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk.Organized extends LOI.Character.Behavior.Perk
  @register 'Organized'
  
  @displayName: "Organized"
  @description: "You like to plan ahead and not stray from the path."
  @requirements: "High Order score."
  @effects: """
        Less random events.
        More organizational tools.
      """

  @satisfiesRequirements: (behaviorPart) ->
    super

    factorPowers = behaviorPart.properties.personality.part.factorPowers()
    organizedScore = factorPowers[3].positive
    organizedScore >= LOI.Character.Behavior.Perk.factorPowerCutoff
