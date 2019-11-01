LOI = LandsOfIllusions

class LOI.Character.Behavior.Perk.DeadEndJob extends LOI.Character.Behavior.Perk
  @register 'DeadEndJob'
  
  @displayName: "Dead-end job"
  @description: "Your work is sucking your soul, but gives you one more reason to change your life around."
  @requirements: "Allocate time for a job."
  @effects: """
        Gain less energy points.
        Gain more motivation points.
      """

  @satisfiesRequirements: (behaviorPart) ->
    super arguments...

    # Search activities for a job with some time allocated to it.
    _.find behaviorPart.properties.activities.parts(), (activityPart) ->
      activityKey = activityPart.properties.key.options.dataLocation()
      activityHoursPerWeek = activityPart.properties.hoursPerWeek.options.dataLocation()

      activityKey is LOI.Character.Behavior.Activity.Keys.Job and activityHoursPerWeek > 0

