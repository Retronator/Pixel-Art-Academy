AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Table.Interaction.Photos extends HQ.Store.Table.Interaction
  @id: -> 'Retronator.HQ.Store.Table.Interaction.Photos'

  @register @id()
  template: -> @constructor.id()

  @defaultScriptUrl: -> 'retronator_retronator-hq/floor2/store/table/interaction/photos/photos.script'

  @initialize()

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

  start: (@startOptions) ->
    listener = @listeners[0]

    if @startOptions.justActivate
      listener.startScript label: 'Activate'
      
    else
      listener.startScript label: if @photos.length is 1 then 'LookAtPhoto' else 'LookAtPhotos'

  provideCallbacks: ->
    LookAtPhotos: (complete) =>
      @interact => complete()
