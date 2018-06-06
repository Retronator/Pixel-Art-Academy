LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps extends LOI.Adventure.Location
  @id: -> 'PixelArtAcademy.PixelBoy.Apps'

  @initialize()

  things: -> [
    @constructor.HomeScreen
    @constructor.StudyPlan
    @constructor.Journal
    @constructor.Calendar
    @constructor.Yearbook
    @constructor.Drawing
    #@constructor.Pico8
  ]
