LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk.CreativeMess extends LOI.Character.Behavior.Perk
  @register 'CreativeMess'
  
  @displayName: "Creative mess"
  @description: "You like your table full of stuff and you wouldn't think about putting anything away."
  @effects: """
        Physical items increase your happiness. 
        Never have to clean.
      """
  @requirements: "High desired level of clutter."

  satisfiesRequirements: ->
    super
    # Override this with custom logic that tests whether the character can have this perk.
