AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

StudyPlan = PAA.PixelPad.Apps.StudyPlan
Markup = PAA.Practice.Helpers.Drawing.Markup
InstructionsSystem = PAA.PixelPad.Systems.Instructions
InterfaceMarking = PAA.Tutorials.Planning.StudyPlan.InterfaceMarking

class PAA.Tutorials.Planning.StudyPlan.Progression
  class @UnlockInstruction extends PAA.Tutorials.Planning.StudyPlan.Instruction
    @levelToBeUnlocked: -> throw new AE.NotImplementedException "Unlock instruction must provide which level is being unlocked."
    
    @delayDuration: -> 2
    
    @priority: -> 2

    activeConditions: ->
      # Show on the progression screen.
      return unless studyPlan = @getStudyPlan()
      return unless studyPlan.showProgression()
      
      # We need to have this level available.
      levelToBeUnlocked = @constructor.levelToBeUnlocked()
      return unless levelToBeUnlocked <= StudyPlan.currentProgressionLevel()
      
      # Only show when we're unlocking this particular level.
      StudyPlan.unlockedProgressionLevel() is levelToBeUnlocked - 1
      
  class @Intro extends @UnlockInstruction
    @id: -> "PixelArtAcademy.Tutorials.Planning.StudyPlan.Progression.Intro"
    @levelToBeUnlocked: -> StudyPlan.ProgressionLevels.Intro
    
    @message: -> """
      Welcome to the Study Plan, your map of art knowledge!
    """
    
    @delayDuration: -> 1
    
    @initialize()
    
    activeConditions: ->
      return unless super arguments...
      
      return unless progression = @getStudyPlan()?.progression()
      
      progression.timelapsePlayed()
      
    activeDisplayState: ->
      return PAA.PixelPad.Systems.Instructions.DisplayStates.Open unless progression = @getStudyPlan()?.progression()
      
      if progression.timelapseReplayed() then PAA.PixelPad.Systems.Instructions.DisplayStates.Closed else PAA.PixelPad.Systems.Instructions.DisplayStates.Open

  class @ShortTermGoals extends @UnlockInstruction
    @id: -> "PixelArtAcademy.Tutorials.Planning.StudyPlan.Progression.ShortTermGoals"
    @levelToBeUnlocked: -> StudyPlan.ProgressionLevels.ShortTermGoals
    
    @message: -> """
      Level up to unlock the ability to add new goals to the Study Plan.
    """

    @initialize()

  class @MidTermGoals extends @UnlockInstruction
    @id: -> "PixelArtAcademy.Tutorials.Planning.StudyPlan.Progression.MidTermGoals"
    @levelToBeUnlocked: -> StudyPlan.ProgressionLevels.MidTermGoals
    
    @message: -> """
      Level up to unlock the ability to plan future goals.
    """
    
    @initialize()

  class @LongTermGoals extends @UnlockInstruction
    @id: -> "PixelArtAcademy.Tutorials.Planning.StudyPlan.Progression.LongTermGoals"
    @levelToBeUnlocked: -> StudyPlan.ProgressionLevels.LongTermGoals
    
    @message: -> """
      Level up to unlock the ultimate tool: backward planning.
    """
    
    @initialize()
