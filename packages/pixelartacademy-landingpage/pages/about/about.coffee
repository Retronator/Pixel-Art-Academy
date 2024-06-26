AM = Artificial.Mirage
LOI = LandsOfIllusions

class PixelArtAcademy.LandingPage.Pages.About extends AM.Component
  @register 'PixelArtAcademy.LandingPage.Pages.About'
    
  @version: -> '0.2.0'

  @title: ->
    "Pixel Art Academy // Learn how to draw pixel art with a video game"

  @description: -> """
    Start from zero and develop your art skills as you become a game artist in real life.
    Complete interactive tutorials, draw pixel art sprites, and play the games you create.
  """

  @image: ->
    Meteor.absoluteUrl "pixelartacademy/title.png"

  onCreated: ->
    super arguments...

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
