AM = Artificial.Mirage
LOI = LandsOfIllusions

class PixelArtAcademy.LandingPage.Pages.About extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.LandingPage.Pages.About'

  @register @id()
  template: -> @constructor.id()

  onCreated: ->
    super

    # Create pixel scaling display.
    @display = new AM.Display
      safeAreaWidth: 320
      safeAreaHeight: 240
      minScale: 2
