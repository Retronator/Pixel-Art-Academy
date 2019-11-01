LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk.Introvert extends LOI.Character.Behavior.Perk
  @register 'Introvert'
  
  @displayName: "Introvert"
  @description: "You don't mind if the whole world is having a party, you're just as happy on your own."
  @requirements: "High Peace score."
  @effects: """
        Immune to social events.
        Less available friend connections.
      """

  @satisfiesRequirements: (behaviorPart) ->
    super arguments...

    factorPowers = behaviorPart.properties.personality.part.factorPowers()
    introversionScore = factorPowers[1].negative
    introversionScore >= LOI.Character.Behavior.Perk.factorPowerCutoff
