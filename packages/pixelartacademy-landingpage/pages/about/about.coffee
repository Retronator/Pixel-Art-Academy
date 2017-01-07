AM = Artificial.Mirage
LOI = LandsOfIllusions

class PixelArtAcademy.LandingPage.Pages.About extends AM.Component
  @register 'PixelArtAcademy.LandingPage.Pages.About'
    
  @version: -> '0.0.1'

  onCreated: ->
    super

    # Create pixel scaling display.
    @display = new AM.Display
      safeAreaWidth: 320
      safeAreaHeight: 240
      minScale: 2
      
    # Add 2x scale class to html so we can scale cursors.
    @autorun (computation) =>
      if @display.scale() is 2
        $('html').addClass('scale-2')

      else
        $('html').removeClass('scale-2')
