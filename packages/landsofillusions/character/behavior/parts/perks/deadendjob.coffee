LOI = LandsOfIllusions

class LOI.Character.Behavior.Perks.DeadEndJob extends LOI.Character.Behavior.Perk
  @key: 'DeadEndJob'
  @name: "Dead-end job"
  @description: "Your work makes you exhaustingly brain-dead, but gives you one more reason to change your life around."
  @effects: """
        Less energy points at start of the day. 
        More motivation points at start of the day.
      """
  @requirements: "Allocate time for a job."

  satisfiesRequirements: ->
    # Override this with custom logic that tests whether the character can have this perk.
