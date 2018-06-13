AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Theme.School.Pico8 extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Theme.School.Pico8'

  constructor: (@options) ->
    super
    
  onCreated: ->
    super

    @device = new PAA.Pico8.Device.Handheld

    # Get all the games.
    PAA.Pico8.Game.all.subscribe @

    @autorun (computation) =>
      return unless asset = @options.asset()
      return unless slug = asset.project.constructor.pico8GameSlug?()
      
      PAA.Pico8.Game.forSlug.subscribe slug
      
      return unless game = PAA.Pico8.Game.documents.findOne {slug}

      @device.loadGame game, asset.project.projectId
