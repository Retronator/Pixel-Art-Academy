LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk.Minimalist extends LOI.Character.Behavior.Perk
  @register 'Minimalist'
  
  @displayName: "Minimalist"
  @description: "An empty room gives your mind place to expand."
  @requirements: "Low ideal level of clutter."
  @effects: """
        You gain motivation points from lack of physical things. 
      """

  @satisfiesRequirements: (behaviorPart) ->
    super

    idealClutter = behaviorPart.properties.environment.part.properties.clutter.part.properties.ideal.options.dataLocation()
    idealClutter < 3
