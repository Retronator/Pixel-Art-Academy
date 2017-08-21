LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk.NothingToClean extends LOI.Character.Behavior.Perk
  @register 'NothingToClean'
  
  @displayName: "Nothing to clean"
  @description: "You're quite fine with how things are around you."
  @requirements: "Average level of clutter is less or same as ideal."
  @effects: """
        No cleaning tasks.
      """

  @satisfiesRequirements: (behaviorPart) ->
    super

    clutterProperties = behaviorPart.properties.environment.part.properties.clutter.part.properties
    idealClutter = clutterProperties.ideal.options.dataLocation()
    averageClutter = clutterProperties.average.options.dataLocation()
    averageClutter <= idealClutter
