AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Challenges.Drawing.PixelArtSoftware.CopyReference.ClipboardPageComponent extends AM.Component
  @register 'PixelArtAcademy.Challenges.Drawing.PixelArtSoftware.CopyReference.ClipboardPageComponent'

  constructor: (@copyReference) ->
    super arguments...

  onCreated: ->
    super arguments...

    @parent = @ancestorComponentWith 'closeSecondPage'

    @autorun (computation) =>
      return unless palette = @copyReference.bitmap()?.palette
      LOI.Assets.Palette.forId.subscribeContent @, palette._id

    @palette = new ComputedField =>
      return unless palette = @copyReference.bitmap()?.palette
      LOI.Assets.Palette.documents.findOne palette._id

  templateStyle: ->
    dimensions = @copyReference.constructor.fixedDimensions()

    # Max width is 90 rem, max height is 60 rem.
    maxWidthScale = 90 / dimensions.width
    maxHeightScale = 60 / dimensions.height
    scale = Math.min maxWidthScale, maxHeightScale

    # Fill the rest of the height with a margin.
    bottomMargin = 60 - dimensions.height * scale

    width: "#{dimensions.width * scale}rem"
    height: "#{dimensions.height * scale}rem"
    marginBottom: "#{bottomMargin}rem"
