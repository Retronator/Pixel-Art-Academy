AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Table.Interaction.Photos extends HQ.Store.Table.Interaction
  @register 'Retronator.HQ.Store.Table.Interaction.Photos'

  constructor: (@photos) ->
    super

  onCreated: ->
    super

    @pixelImages = for photo in @photos
      new AM.PixelImage
        source: photo.original_size.url

  onRendered: ->
    super

    for pixelImage in @pixelImages
      do (pixelImage) =>
        @autorun (computation) =>
          return unless sourceWidth = pixelImage.sourceWidth()
          sourceHeight = pixelImage.sourceHeight()

          Tracker.nonreactive =>
            targetWidth = Math.min sourceWidth, 100
            targetHeight = Math.min sourceHeight, 240
            widthScale = targetWidth / sourceWidth
            heightScale = targetHeight / sourceHeight
            scale = Math.min widthScale, heightScale

            pixelImage.targetWidth sourceWidth * scale
            pixelImage.targetHeight sourceHeight * scale

  addPhoto: (photo) ->
    @photos.push photo

  illustrationHeight: ->
    100
