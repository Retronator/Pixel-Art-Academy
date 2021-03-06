AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.Pages.Pico8 extends AM.Component
  @register 'PixelArtAcademy.Pico8.Pages.Pico8'

  @title: -> "PICO-8"
  @webApp: -> true
  @viewport: -> 'user-scalable=no, width=640'
  @touchIcon: -> '/pixelartacademy/pico8/pages/pico8/apple-touch-icon.png'

  onCreated: ->
    super arguments...

    @display = new AM.Display
      safeAreaWidth: 320
      safeAreaHeight: 155
      minScale: 2

    # Get all the games.
    PAA.Pico8.Game.all.subscribe @

    @device = new PAA.Pico8.Device.Handheld

    @autorun (computation) =>
      return unless slug = AB.Router.getParameter 'gameSlug'
      return unless game = PAA.Pico8.Game.documents.findOne {slug}

      projectId = AB.Router.getParameter 'projectId'

      @device.loadGame game, projectId
