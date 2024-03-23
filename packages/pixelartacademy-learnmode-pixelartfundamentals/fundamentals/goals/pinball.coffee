LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Goals.Pinball extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Pinball'

  @displayName: -> "Pinball"

  @chapter: -> LM.PixelArtFundamentals.Fundamentals

  Goal = @
  
  class @Play extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.Play"
    @goal: -> Goal

    @directive: -> "Open your pinball machine"

    @instructions: -> """
      In the Pixeltosh app, open the Pinball Creation Kit drive and open the Pinball Machine file.
    """

    @interests: -> ['pinball', 'gaming']

    @requiredInterests: -> ['smooth curve (pixel art)']

    @initialize()

    @completedConditions: -> LM.PixelArtFundamentals.Fundamentals.state 'openedPinballMachine'
    
  @tasks: -> [
    @Play
  ]

  @finalTasks: -> [
  ]

  @initialize()
