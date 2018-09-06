AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Asset.Sprite.ClipboardPageComponent extends AM.Component
  @register 'PixelArtAcademy.Practice.Project.Asset.Sprite.ClipboardPageComponent'

  constructor: (@sprite) ->
    super

  onCreated: ->
    super

    @parent = @ancestorComponentWith 'closeSecondPage'

    @autorun (computation) =>
      return unless palette = @sprite.sprite()?.palette
      LOI.Assets.Palette.forId.subscribe @, palette._id

    @palette = new ComputedField =>
      return unless palette = @sprite.sprite()?.palette
      LOI.Assets.Palette.documents.findOne palette._id
