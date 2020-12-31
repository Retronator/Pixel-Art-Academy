AE = Artificial.Everywhere
AS = Artificial.Spectrum
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Thumbnail.Pictures
  constructor: (@pictures) ->

  bounds: ->
    bounds = null

    for picture in @pictures
      continue unless pictureBounds = picture.bounds()

      pictureBoundsRectangle = AE.Rectangle.fromDimensions pictureBounds

      if bounds
        bounds = bounds.union pictureBoundsRectangle

      else
        bounds = pictureBoundsRectangle

    bounds?.toObject()

  drawToContext: (context) ->
    for thumbnailPicture in @pictures
      thumbnailPicture.drawToContext context
