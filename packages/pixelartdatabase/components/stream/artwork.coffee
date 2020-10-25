AB = Artificial.Base
AM = Artificial.Mirage
AS = Artificial.Spectrum
PADB = PixelArtDatabase

class PADB.Components.Stream.Artwork extends AM.Component
  @register 'PixelArtDatabase.Components.Stream.Artwork'

  constructor: (@options) ->
    super arguments...

  onCreated: ->
    super arguments...

    @image = new ReactiveField null

    # Update image based on image URL.
    @autorun (computation) =>
      displayedArtwork = @data()
      {imageUrl, imageElement} = displayedArtwork

      image = null
      onImageLoad = =>
        # Calculate pixel scale if needed.
        unless displayedArtwork.artwork.nonPixelArt
          image.pixelScale = displayedArtwork.artwork.image?.pixelScale

          unless image.pixelScale
            detectPixelScaleOptions = {}

            # Mark jpegs as compressed.
            if imageUrl.match /\.jpe?g$/
              detectPixelScaleOptions.compressed = true

            image.pixelScale = AS.PixelArt.detectPixelScale image, detectPixelScaleOptions

        @image image

      if imageElement
        image = imageElement
        onImageLoad()
        return

      if _.endsWith imageUrl, 'gif'
        AS.PreviewGIF imageUrl, (error, imageData) =>
          if error
            console.error error
            return

          image = new Image
          image.onload = onImageLoad
          image.src = imageData

      else
        image = new Image
        image.crossOrigin = "Anonymous"
        image.onload = onImageLoad
        image.src = imageUrl

  onRendered: ->
    super arguments...

    if @options.display
      @display = @options.display

    else
      parentWithDisplay = @ancestorComponentWith 'display'
      @display = parentWithDisplay.display

    @$artworkArea = @$('.artwork-area')
    @$backgroundCanvas = @$('.background')
    @backgroundCanvas = @$backgroundCanvas[0]
    @backgroundContext = @backgroundCanvas.getContext '2d'

    # Update background when artwork-area size changes.
    @_areaResizedDependency = new Tracker.Dependency
    @_resizeObserver = new ResizeObserver => @_areaResizedDependency.changed()
    @_resizeObserver.observe @$artworkArea[0]

    @autorun (computation) =>
      displayedArtwork = @data()
      return unless image = @image()

      # Depend on area size and scale changes.
      displayScale = @display.scale()
      @_areaResizedDependency.depend()

      # Give time to the artwork to resize first since we'll be measuring the desired background height.
      Meteor.setTimeout =>
        @_renderBackground displayedArtwork, image, displayScale

        # Display the background and image for the first time.
        @$('.background').addClass 'visible'
        @$('.artwork').addClass 'visible'
      ,
        0

  onDestroyed: ->
    super arguments...

    @_resizeObserver.disconnect()

  artworkStyle: ->
    # We need to be rendered to know the width of the artwork frame.
    return unless @isRendered()

    # Only apply custom scale to pixel art images.
    return unless image = @image()

    unless image.pixelScale
      # Non-pixel art images should have smooth interpolation and limited height.
      return {
        imageRendering: 'auto'
        maxHeight: '130vh'
      }

    imageScale = image.pixelScale

    # Calculate how much the image should be upscaled.
    desiredImageScale = 1
    sourceWidth = image.naturalWidth / imageScale
    sourceHeight = image.naturalHeight / imageScale

    # Depend on window size changes.
    clientBounds = AM.Window.clientBounds()
    clientHeight = clientBounds.height()
    artworkFrameWidth = @$('.artwork-frame').width()

    # Increase desired image until we reach certain limits.
    loop
      # Don't go over scale of 8.
      break if desiredImageScale is 8

      # Don't go over scale of 2 if we'd cover more than the screen height.
      nextDisplayHeight = sourceHeight * (desiredImageScale + 1)
      break if desiredImageScale >= 2 and nextDisplayHeight > clientHeight

      # Don't increase scale if we've covered at least half the artwork frame width.
      displayWidth = sourceWidth * desiredImageScale
      break if displayWidth > artworkFrameWidth * 0.5

      # No limits were reached, increase scale.
      desiredImageScale++

    # Don't let the image be bigger than the frame.
    if sourceWidth * desiredImageScale > artworkFrameWidth
      desiredImageScale = artworkFrameWidth / sourceWidth

    # Calculate how much to actually scale the image since the source image already has a certain scale built-in.
    cssScale = desiredImageScale / imageScale

    # Output the size.
    width: image.naturalWidth * cssScale
    height: image.naturalHeight * cssScale

  hasCaption: ->
    @options.captionComponentClass?

  renderCaption: ->
    @caption = new @options.captionComponentClass
    @caption.renderComponent @currentComponent()
