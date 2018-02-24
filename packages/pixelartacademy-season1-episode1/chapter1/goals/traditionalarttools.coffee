PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.TraditionalArtTools extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.TraditionalArtTools'

  @displayName: -> "Traditional art tools"

  Goal = @

  class @ChooseMedium extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.TraditionalArtTools.ChooseMedium'
  
    @directive: -> "Choose a traditional drawing medium"
  
    @instructions: -> """
      With the Drawing app on PixelBoy, choose a traditional drawing (or painting) medium you want to complete drawing assignments in.
    """

    @interests: -> ['traditional art']

    @initialize()

  @tasks: -> [
    @ChooseMedium
  ]

  @finalTasks: -> [
    @ChooseMedium
  ]

  @initialize()
