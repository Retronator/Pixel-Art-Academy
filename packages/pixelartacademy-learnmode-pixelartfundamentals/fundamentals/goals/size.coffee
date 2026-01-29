AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Goals.Size extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Size'

  @displayName: -> "Pixel art fundamentals: size"
  
  @chapter: -> LM.PixelArtFundamentals.Fundamentals

  Goal = @

  class @Learn extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Size.Learn'
    @goal: -> Goal

    @directive: -> "Learn about pixel art size"

    @instructions: -> """
      In the Drawing app, complete the Pixel art size tutorial to learn which factors go into deciding how big to make your pixel art.
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @requiredInterests: -> ['simplification']
    
    @studyPlanBuilding: -> 'SimCityCommercial3'
    
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtFundamentals.Size.completed()
  
  class @Icon extends PAA.Learning.Task.Automatic
    @goal: -> Goal
    @size: -> throw new AE.NotImplementedException "Icon task must define the size of the icon."
    @sizeString: ->
      size = @size()
      "#{size}×#{size}"
      
    @instructions: -> """
      In the Drawing app, pick a subject in the Pixel art readability challenge and choose the #{@sizeString()} size.
      Complete and refine your drawing until the Pixeltosh correctly guesses your subject in the readability analysis.
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @predecessors: -> [Goal.Learn]
    
  class @Icon8 extends @Icon
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Size.Icon8'
    @size: -> 8
    
    @directive: -> "Draw an #{@sizeString()} icon"
    
    @groupNumber: -> -1
    
    @studyPlanBuilding: -> 'SimCityResidential1'
    
    @initialize()
    
    @completedConditions: -> false
  
  class @Icon16 extends @Icon
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Size.Icon16'
    @size: -> 16
    
    @directive: -> "Draw a #{@sizeString()} icon"
    
    @interests: -> ['size (pixel art)']
    
    @studyPlanBuilding: -> 'TransportTycoonCinema'
    
    @initialize()
    
    @completedConditions: -> false
  
  class @Icon32 extends @Icon
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Size.Icon32'
    @size: -> 32
    
    @directive: -> "Draw a #{@sizeString()} icon"
    
    @groupNumber: -> 1
    
    @studyPlanBuilding: -> 'SimCityOffice3'
    
    @initialize()
    
    @completedConditions: -> false
  
  @tasks: -> [
    @Learn
    @Icon8
    @Icon16
    @Icon32
  ]

  @finalTasks: -> [
    @Icon16
  ]

  @initialize()
