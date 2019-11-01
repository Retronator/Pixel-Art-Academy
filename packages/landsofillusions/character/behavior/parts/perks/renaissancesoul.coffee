LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk.RenaissanceSoul extends LOI.Character.Behavior.Perk
  @register 'RenaissanceSoul'
  
  @displayName: "Renaissance soul"
  @description: "You have too many passions to pick just one. Da Vinci would be proud!"
  @requirements: "Allocate time to 3 or more personal activities."
  @effects: """
        One extra interest slot.
        Slower interest development.
      """

  @satisfiesRequirements: (behaviorPart) ->
    super arguments...

    numberOfPersonalActivities = behaviorPart.properties.activities.activePersonalActivities().length
    numberOfPersonalActivities >= 3
