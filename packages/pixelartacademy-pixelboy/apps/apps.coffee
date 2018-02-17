LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps extends LOI.Adventure.Location
  @id: -> 'PixelArtAcademy.PixelBoy.Apps'

  @initialize()

  things: -> [
    @constructor.HomeScreen
    @constructor.Drawing
    @constructor.Journal
    @constructor.Pico8
    @constructor.StudyPlan
  ]
