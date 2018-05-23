AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  constructor: (@drawing) ->
    super

    @theme = new ReactiveField null

    @spriteId = new ReactiveField null

    @spriteData = new ComputedField =>
      spriteId = @spriteId()
      LOI.Assets.Sprite.documents.findOne spriteId

  destroy: ->
    super

    @spriteData.stop()

  onCreated: ->
    super

    @theme new @constructor.Theme.School @

    # Only update spriteId when it has a value, to prevent from destroying the sprite during transitions.
    @autorun (computation) =>
      return unless spriteId = AB.Router.getParameter 'parameter3'

      @spriteId spriteId

  active: ->
    AB.Router.getParameter('parameter4') is 'edit'
