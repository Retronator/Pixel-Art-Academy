AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.Components.Stream extends AM.Component
  @register 'PixelArtDatabase.Components.Stream'

  constructor: (captionComponentClassOrOptions = {}) ->
    super arguments...

    if _.isFunction captionComponentClassOrOptions
      @options =
        captionComponentClass: captionComponentClassOrOptions

    else
      @options = captionComponentClassOrOptions

  onCreated: ->
    super arguments...

    @playbackSkippedCount = 0

    @displayedArtworks = new ComputedField =>
      artworks = @data()
      return unless artworks

      # Add extra data to artworks.
      for artwork in artworks
        displayedArtwork =
          artwork: artwork

        if artwork.image
          displayedArtwork.imageUrl ?= artwork.image.url or artwork.image.src

          if artwork.image instanceof HTMLImageElement
            displayedArtwork.imageElement = artwork.image

        if artwork.representations
          for representation in artwork.representations
            if representation.type is PADB.Artwork.RepresentationTypes.Image
              displayedArtwork.imageUrl ?= representation.url

            if representation.type is PADB.Artwork.RepresentationTypes.Video
              displayedArtwork.videoUrl ?= representation.url

        displayedArtwork

    @_artworksVisibilityData = []

  onRendered: ->
    super arguments...
    
    if @options.scrollParentSelector
      @_$scrollParent = $(@options.scrollParentSelector)

    else
      @_$scrollParent = $(window)

    @_$scrollParent.on 'scroll.pixelartdatabase-components-stream', (event) => @onScroll()

    # Update active artwork areas on resizes and artwork updates.
    @autorun (computation) =>
      AM.Window.clientBounds()
      @displayedArtworks()

      # Wait till the new artwork areas get rendered.
      Tracker.afterFlush =>
        # Everything is deactivated when first rendered so make sure visibility data reflects that.
        visibilityData.active = false for visibilityData in @_artworksVisibilityData

        @_measureArtworkAreas()
        @_updateArtworkAreasVisibility()

  onDestroyed: ->
    super arguments...

    @_$scrollParent.off '.pixelartdatabase-components-stream'

  artworkOptions: ->
    @options

  onScroll: ->
    # Measure artwork areas every 2s when scrolling.
    @_throttledMeasureArtworkAreas ?= _.throttle =>
      @_measureArtworkAreas()
      @_updateArtworkAreasVisibility()
    ,
      2000

    # Update visibility every 0.2s when scrolling.
    @_throttledUpdateArtworkAreasVisibility ?= _.throttle =>
      @_updateArtworkAreasVisibility()
    ,
      200
    
    @_throttledMeasureArtworkAreas()
    @_throttledUpdateArtworkAreasVisibility()

  _measureArtworkAreas: ->
    # Get top and bottom positions of all artworks.
    $artworkAreas = @$('.artwork-area')
    return unless $artworkAreas

    for artworkAreaElement, index in $artworkAreas
      $artworkArea = $(artworkAreaElement)
      top = $artworkArea.offset().top

      # When we're scrolling inside a fixed parent, the offset needs to be adjusted by the
      # scroll amount so that we get the position relative to the scrolling parent.
      top += @_$scrollParent.scrollTop() if @options.scrollParentSelector

      bottom = top + $artworkArea.height()

      @_artworksVisibilityData[index] ?= {}
      @_artworksVisibilityData[index].element = artworkAreaElement
      @_artworksVisibilityData[index].$artworkArea = $artworkArea
      @_artworksVisibilityData[index].top = top
      @_artworksVisibilityData[index].bottom = bottom

      displayedArtwork = Blaze.getData(artworkAreaElement)
      @_artworksVisibilityData[index].artwork = displayedArtwork.artwork

  _updateArtworkAreasVisibility: ->
    scrollParentTop = if @options.scrollParentSelector then @_$scrollParent.offset().top else 0
    viewportTop = scrollParentTop + @_$scrollParent.scrollTop()
    scrollParentHeight = @_$scrollParent.height()
    viewportBottom = viewportTop + scrollParentHeight

    # Expand one extra screen beyond the viewport
    visibilityEdgeTop = viewportTop - scrollParentHeight
    visibilityEdgeBottom = viewportBottom + scrollParentHeight

    # Go over all the artworks and activate the visible ones.
    for visibilityData, index in @_artworksVisibilityData
      # Artwork is visible if it is anywhere in between the visibility edges.
      artworkShouldBeActive = visibilityData.bottom > visibilityEdgeTop and visibilityData.top < visibilityEdgeBottom

      # Activate or deactivate artwork areas. Note that active is undefined at the start.
      if artworkShouldBeActive and visibilityData.active isnt true
        # We must activate this artwork area.
        visibilityData.active = true

        # Play all the videos in this area.
        $artworkArea = visibilityData.$artworkArea
        $videos = $artworkArea.find('video')

        playPromises = for video in $videos
          promise = video.play()

          do (video) =>
            promise?.then =>
              video.pause()

          promise

        do ($videos) =>
          Promise.all(playPromises).then =>
            Meteor.setTimeout =>
              for video in $videos
                video.currentTime = 0
                video.play()
            ,
              500

            # HACK: Safari sometimes hides the video after it starts playing, so we trigger it to be re-rendered.
            $videos.css
              display: 'inline-block'

      else if not artworkShouldBeActive and visibilityData.active isnt false
        # We need to deactivate this artwork area.
        visibilityData.active = false

        # Stop all the videos in the area.
        $artworkArea = visibilityData.$artworkArea
        video.pause() for video in $artworkArea.find('video')
