AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.Components.Stream extends AM.Component
  @register 'PixelArtDatabase.Components.Stream'

  constructor: (@captionComponentClass) ->
    super

  onCreated: ->
    super

    @lowPerformance = new ReactiveField false
    @playbackSkippedCount = 0

    @displayedArtworks = new ComputedField =>
      artworks = @data()
      return unless artworks

      # Add extra data to artworks.
      for artwork in artworks
        displayedArtwork =
          artwork: artwork
          
        for representation in artwork.representations
          if representation.type is PADB.Artwork.RepresentationTypes.Image
            displayedArtwork.imageUrl ?= representation.url

          if representation.type is PADB.Artwork.RepresentationTypes.Video
            displayedArtwork.videoUrl ?= representation.url

        displayedArtwork

    @_artworksVisibilityData = []

  onRendered: ->
    super
    @_$window = $(window)
    @_$document = $(document)
    @_$app = $('.retronator-app')

    @_$window.on 'scroll.pixelartdatabase-components-stream', (event) => @onScroll()

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
    super

    @_$window.off '.pixelartdatabase-components-stream'

  hasCaption: ->
    @captionComponentClass?

  renderCaption: ->
    caption = new @captionComponentClass
    caption.renderComponent @currentComponent()
    
  lowPerformanceClass: ->
    'low-performance' if @lowPerformance()

  showVideoBackground: ->
    artwork = @currentData()

    # Show the video background if this is an animated artwork and we're not in low performance mode.
    artwork.videoUrl and not @lowPerformance()

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
      bottom = top + $artworkArea.height()

      @_artworksVisibilityData[index] ?= {}
      @_artworksVisibilityData[index].element = artworkAreaElement
      @_artworksVisibilityData[index].$artworkArea = $artworkArea
      @_artworksVisibilityData[index].top = top
      @_artworksVisibilityData[index].bottom = bottom

      displayedArtwork = Blaze.getData(artworkAreaElement)
      @_artworksVisibilityData[index].artwork = displayedArtwork.artwork

  _updateArtworkAreasVisibility: ->
    viewportTop = @_$window.scrollTop()
    windowHeight = @_$window.height()
    viewportBottom = viewportTop + windowHeight

    # Expand one extra screen beyond the viewport
    visibilityEdgeTop = viewportTop - windowHeight
    visibilityEdgeBottom = viewportBottom + windowHeight

    # Go over all the artworks and activate the ones
    for visibilityData, index in @_artworksVisibilityData
      # Artwork is visible if it is anywhere in between the visibility edges.
      artworkShouldBeActive = visibilityData.bottom > visibilityEdgeTop and visibilityData.top < visibilityEdgeBottom

      # Activate or deactivate artwork areas. Note that active is undefined at the start.
      if artworkShouldBeActive and visibilityData.active isnt true
        # We must activate this artwork area.
        visibilityData.active = true

        $artworkArea = visibilityData.$artworkArea

        $artworkArea.css
          visibility: 'visible'

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

        $backgroundVideo = $artworkArea.find('video.background')
        backgroundVideo = $backgroundVideo[0]

        if backgroundVideo
          $backgroundVideo.on 'timeupdate', =>
            return unless backgroundVideo

            newTime = backgroundVideo.currentTime
            lastTime = $backgroundVideo._lastTime

            if lastTime and newTime - lastTime > 0.55
              @playbackSkippedCount++
              @lowPerformance true if @playbackSkippedCount > 2

            $backgroundVideo._lastTime = newTime

      else if not artworkShouldBeActive and visibilityData.active isnt false
        # We need to deactivate this artwork area.
        visibilityData.active = false

        $artworkArea = visibilityData.$artworkArea

        $artworkArea.css
          visibility: 'hidden'

        for video in $artworkArea.find('video')
          video.pause()

        $backgroundVideo = $artworkArea.find('video.background')
        $backgroundVideo.off 'timeupdate'
