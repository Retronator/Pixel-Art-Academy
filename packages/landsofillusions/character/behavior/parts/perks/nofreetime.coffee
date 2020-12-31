LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk.NoFreeTime extends LOI.Character.Behavior.Perk
  @register 'NoFreeTime'
  
  @displayName: "No free time"
  @description: "There's not much more you could squeeze out of the day, even if you wanted to."
  @requirements: "Less than 5 extra hours per day."
  @effects: """
        Can't do multiple game days in a row.
        Leftover points don't lower motivation.
      """

  @satisfiesRequirements: (behaviorPart) ->
    super arguments...

    behaviorPart.properties.activities.extraHoursPerDay() < 5
