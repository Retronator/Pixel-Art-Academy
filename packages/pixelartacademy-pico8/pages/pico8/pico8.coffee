AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.Pages.Pico8 extends AM.Component
  @register 'PixelArtAcademy.Pico8.Pages.Pico8'

  @title: -> "PICO-8"
  @webApp: -> true
  @viewport: -> 'user-scalable=no, width=640'
  @touchIcon: -> Meteor.absoluteUrl "pixelartacademy/pico8/pages/pico8/touch-icon.png"

  onCreated: ->
    super

    @display = new AM.Display
      safeAreaWidth: 320
      safeAreaHeight: 155
      minScale: 2

    # Get all the games.
    PAA.Pico8.Game.all.subscribe @

    @device = new PAA.Pico8.Device.Handheld
    
    @game = new ComputedField =>
      return unless slug = AB.Router.getParameter 'game'
      PAA.Pico8.Game.documents.findOne {slug}
