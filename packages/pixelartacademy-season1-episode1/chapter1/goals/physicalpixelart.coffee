PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.PhysicalPixelArt extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PhysicalPixelArt'

  @displayName: -> "Physical pixel art"

  Goal = @

  class @ChooseMedium extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PhysicalPixelArt.ChooseMedium'
  
    @directive: -> "Choose a pixel art medium"
  
    @instructions: -> """
      With the Drawing app on PixelBoy, choose one of the physical mediums that can be used to create pixel art.
    """

    @interests: -> ['pixel art', 'traditional art']

    @initialize()

  @tasks: -> [
    @ChooseMedium
  ]

  @finalTasks: -> [
    @ChooseMedium
  ]

  @initialize()
