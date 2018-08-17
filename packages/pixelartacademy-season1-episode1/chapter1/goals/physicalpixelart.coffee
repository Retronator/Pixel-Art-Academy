PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.PhysicalPixelArt extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PhysicalPixelArt'

  @displayName: -> "Physical pixel art"

  @chapter: -> C1

  Goal = @

  class @ChooseMedium extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PhysicalPixelArt.ChooseMedium'
  
    @directive: -> "Choose a pixel art medium"
  
    @instructions: -> """
      With the Drawing app on PixelBoy, choose one of the physical mediums that can be used to create pixel art.
    """

    @initialize()

  class @Reference extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PhysicalPixelArt.Reference'

    @directive: -> "Display a reference"

    @instructions: -> """
      Figure out how you’ll look at a reference image when crafting (display it on a screen or print it out).
    """

    @predecessors: -> [Goal.ChooseMedium]

    @initialize()

  class @Prepare extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PhysicalPixelArt.Doodling'

    @directive: -> "Prepare crafting materials"

    @instructions: -> """
      Choose an object from the reference image and prepare the materials you'll need to recreate it in your medium.
    """

    @predecessors: -> [Goal.Reference]

    @initialize()

  class @CopyReference extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.PhysicalPixelArt.CopyReference'

    @directive: -> "Copy the reference"

    @instructions: -> """
      Recreate the referenced object in your chosen medium.
    """

    @interests: -> ['pixel art', 'crafts']

    @predecessors: -> [Goal.Prepare]

    @initialize()

  @tasks: -> [
    @ChooseMedium
    @Reference
    @Prepare
    @CopyReference
  ]

  @finalTasks: -> [
    @CopyReference
  ]

  @initialize()
