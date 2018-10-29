LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk.Competitor extends LOI.Character.Behavior.Perk
  @register 'Competitor'
  
  @displayName: "Competitor"
  @description: "You like to go at it alone and take all the glory."
  @requirements: "High Independence score."
  @effects: """
        Can attend multiple competitions at the same time.
        Can't ask friends for help.
      """

  @satisfiesRequirements: (behaviorPart) ->
    super arguments...

    factorPowers = behaviorPart.properties.personality.part.factorPowers()
    independenceScore = factorPowers[3].negative
    independenceScore >= LOI.Character.Behavior.Perk.factorPowerCutoff
