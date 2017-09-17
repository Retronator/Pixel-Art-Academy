LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk.Spontaneous extends LOI.Character.Behavior.Perk
  @register 'Spontaneous'
  
  @displayName: "Spontaneous"
  @description: "You like to let the unpredictability of life guide your decisions."
  @requirements: "High Spontaneity score."
  @effects: """
        More random events.
        Less organizational tools.
      """

  @satisfiesRequirements: (behaviorPart) ->
    super

    factorPowers = behaviorPart.properties.personality.part.factorPowers()
    spontaneityScore = factorPowers[3].negative
    spontaneityScore >= LOI.Character.Behavior.Perk.factorPowerCutoff
