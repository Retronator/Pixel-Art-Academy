LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk.DeadEndJob extends LOI.Character.Behavior.Perk
  @register 'DeadEndJob'
  
  @displayName: "Dead-end job"
  @description: "Your work makes you exhaustingly brain-dead, but gives you one more reason to change your life around."
  @effects: """
        Less energy points at start of the day. 
        More motivation points at start of the day.
      """
  @requirements: "Allocate time for a job."

  @satisfiesRequirements: (behaviorPart) ->
    super

    # Search activities for a job with some time allocated to it.
    _.find behaviorPart.properties.activities.parts(), (activityPart) ->
      activityKey = activityPart.properties.key.options.dataLocation()
      activityHoursPerWeek = activityPart.properties.hoursPerWeek.options.dataLocation()

      activityKey is LOI.Character.Behavior.Activity.Keys.Job and activityHoursPerWeek > 0

