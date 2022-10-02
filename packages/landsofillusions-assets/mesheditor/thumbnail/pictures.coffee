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

      pictureBoundsRectangle = new AE.Rectangle pictureBounds

      if bounds
        bounds = AE.Rectangle.union bounds, pictureBoundsRectangle

      else
        bounds = pictureBoundsRectangle

    bounds?.toObject()

  drawToContext: (context) ->
    for thumbnailPicture in @pictures
      thumbnailPicture.drawToContext context
