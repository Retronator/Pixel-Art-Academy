AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Table.Interaction.Photos extends HQ.Store.Table.Interaction
  @register 'Retronator.HQ.Store.Table.Interaction.Photos'

  constructor: (@photos) ->
    super

    @_illustrationHeight = new ReactiveField 0

  onCreated: ->
    super

    @pixelImages = for photo in @photos
      new AM.PixelImage
        source: photo.original_size.url

    # Search for the first parent that has a display.
    parentWithDisplay = @ancestorComponentWith 'display'
    @display = parentWithDisplay.display

  onRendered: ->
    super

    for pixelImage in @pixelImages
      do (pixelImage) =>
        @autorun (computation) =>
          return unless sourceWidth = pixelImage.sourceWidth()
          sourceHeight = pixelImage.sourceHeight()

          Tracker.nonreactive =>
            targetWidth = Math.min sourceWidth, 320
            targetHeight = sourceHeight
            widthScale = targetWidth / sourceWidth
            heightScale = targetHeight / sourceHeight
            scale = Math.min widthScale, heightScale

            pixelImage.targetWidth sourceWidth * scale
            pixelImage.targetHeight sourceHeight * scale

            # Measure new dimensions
            Tracker.afterFlush =>
              screenHeight = @$('.retronator-hq-store-table-interaction-photos').outerHeight()
              displayScale = @display.scale()

              displayHeight = screenHeight / displayScale

              @_illustrationHeight displayHeight

  addPhoto: (photo) ->
    @photos.push photo

  illustrationHeight: ->
    @_illustrationHeight()
