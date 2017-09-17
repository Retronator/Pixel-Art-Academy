LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk.CreativeMess extends LOI.Character.Behavior.Perk
  @register 'CreativeMess'
  
  @displayName: "Creative mess"
  @description: "A table full of things is a table full of ideas."
  @requirements: "High ideal level of clutter."
  @effects: """
        Physical items increase your motivation points. 
      """

  @satisfiesRequirements: (behaviorPart) ->
    super

    idealClutter = behaviorPart.properties.environment.part.properties.clutter.part.properties.ideal.options.dataLocation()
    idealClutter > 3
