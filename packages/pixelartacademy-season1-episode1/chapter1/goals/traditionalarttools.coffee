PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.TraditionalArtTools extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.TraditionalArtTools'

  @displayName: -> "Traditional art tools"

  @chapter: -> C1

  Goal = @

  class @ChooseMedium extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.TraditionalArtTools.ChooseMedium'
  
    @directive: -> "Choose a traditional drawing medium"
  
    @instructions: -> """
      With the Drawing app on PixelBoy, choose a traditional drawing (or painting) medium you want to complete drawing assignments in.
    """

    @initialize()

  class @Doodling extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.TraditionalArtTools.Doodling'

    @directive: -> "Doodling"

    @instructions: -> """
      Using the medium that you chose, try out different pens, pencils, brushes … See how they behave if you vary pressure or angle.
      Take a photo of your doodles and upload it to your practice journal.
    """

    @predecessors: -> [Goal.ChooseMedium]

    @initialize()

  class @Reference extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.TraditionalArtTools.Reference'

    @directive: -> "Display a reference"

    @instructions: -> """
      Figure out how you’ll look at a reference image when drawing (display it on a screen or print it out).
    """

    @predecessors: -> [Goal.Doodling]

    @initialize()

  class @CopyReference extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.TraditionalArtTools.CopyReference'

    @directive: -> "Copy the reference"

    @instructions: -> """
      Choose one of the objects in the reference and copy it to the best of your ability.
    """

    @interests: -> ['traditional art']

    @predecessors: -> [Goal.Reference]

    @initialize()

  @tasks: -> [
    @ChooseMedium
    @Doodling
    @Reference
    @CopyReference
  ]

  @finalTasks: -> [
    @CopyReference
  ]

  @initialize()
