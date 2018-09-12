AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.PixelArtSoftware.CopyReference.ClipboardPageComponent extends AM.Component
  @register 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.PixelArtSoftware.CopyReference.ClipboardPageComponent'

  constructor: (@copyReference) ->
    super

  onCreated: ->
    super

    @parent = @ancestorComponentWith 'closeSecondPage'

    @autorun (computation) =>
      return unless palette = @copyReference.sprite()?.palette
      LOI.Assets.Palette.forId.subscribe @, palette._id

    @palette = new ComputedField =>
      return unless palette = @copyReference.sprite()?.palette
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
