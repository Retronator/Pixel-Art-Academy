LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt'

  @displayName: -> "Elements of art"
  
  @chapter: -> LM.PixelArtFundamentals.Fundamentals

  Goal = @

  class @Line extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt.Line'
    @goal: -> Goal

    @directive: -> "Learn about lines"

    @instructions: -> """
      In the Drawing app, complete the Elements of art: line tutorial to learn about the most foundational element of art.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @interests: -> ['line']
  
    @requiredInterests: -> ['pixel art software', 'learn mode tutorial project']
    
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.ElementsOfArt.Line.completed()
    
    Task = @
    
  class @Shape extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt.Shape'
    @goal: -> Goal
    
    @directive: -> "Learn about shapes"
    
    @instructions: -> """
      In the Drawing app, complete the Elements of art: shape tutorial to learn about drawing things out of shapes.
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @predecessors: -> [Goal.Line]
    
    @interests: -> ['shape']
    
    @groupNumber: -> -1
    
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.ElementsOfArt.Shape.completed()
    
    Task = @

  class @Color extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt.Color'
    @goal: -> Goal
    
    @directive: -> "Learn about colors"
    
    @instructions: -> """
        In the Drawing app, complete the Elements of art: color tutorial to learn about giving color to shapes.
      """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @predecessors: -> [Goal.Shape]
    
    @interests: -> ['color']

    @groupNumber: -> -1
    
    @initialize()
    
    @completedConditions: ->
      # TODO: Tie to tutorial completion.
      false
    
    Task = @
  
  class @Form extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt.Form'
    @goal: -> Goal
    
    @directive: -> "Learn about form"
    
    @instructions: -> """
        In the Drawing app, complete the Elements of art: form tutorial to learn about the 3D nature of objects.
      """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @predecessors: -> [Goal.Line]
    
    @interests: -> ['form']

    @requiredInterests: -> ['sketching']
    
    @groupNumber: -> 1
    
    @initialize()
    
    @completedConditions: ->
      # TODO: Tie to tutorial completion.
      false
    
    Task = @
  
  class @Space extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt.Space'
    @goal: -> Goal
    
    @directive: -> "Learn about space"
    
    @instructions: -> """
        In the Drawing app, complete the Elements of art: space tutorial to learn about the distribution of elements in artworks.
      """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @predecessors: -> [Goal.Form]
    
    @interests: -> ['space']
    
    @requiredInterests: -> ['scene']
    
    @initialize()
    
    @groupNumber: -> 2
    
    @completedConditions: ->
      # TODO: Tie to tutorial completion.
      false
    
    Task = @
  
  class @Value extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt.Value'
    @goal: -> Goal
    
    @directive: -> "Learn about value"
    
    @instructions: -> """
        In the Drawing app, complete the Elements of art: value tutorial to learn about shading.
      """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @predecessors: -> [Goal.Form]
    
    @interests: -> ['value']
    
    @requiredInterests: -> ['lighting']
    
    @groupNumber: -> 1
    
    @initialize()
    
    @completedConditions: ->
      # TODO: Tie to tutorial completion.
      false
    
    Task = @

  class @Texture extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt.Texture'
    @goal: -> Goal
    
    @directive: -> "Learn about texture"
    
    @instructions: -> """
        In the Drawing app, complete the Elements of art: texture tutorial to learn about detailed materials.
      """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @predecessors: -> [Goal.Color, Goal.Value]
    
    @interests: -> ['texture']
    
    @initialize()
    
    @completedConditions: ->
      # TODO: Tie to tutorial completion.
      false
    
    Task = @
    
  @tasks: -> [
    @Line
    @Shape
    @Color
    @Form
    @Space
    @Value
    @Texture
  ]

  @finalTasks: -> [
    @Space
    @Texture
  ]

  @initialize()
