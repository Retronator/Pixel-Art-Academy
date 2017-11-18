LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk.Focused extends LOI.Character.Behavior.Perk
  @register 'Focused'
  
  @displayName: "Focused"
  @description: "You like to get one thing done at a time."
  @requirements: "Allocate time to at most 2 personal activities."
  @effects: """
        One less interest slot.
        Faster interest development.
      """

  @satisfiesRequirements: (behaviorPart) ->
    super

    numberOfPersonalActivities = behaviorPart.properties.activities.activePersonalActivities().length
    numberOfPersonalActivities <= 2
