AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.Components.Stream extends AM.Component
  @register 'PixelArtDatabase.Components.Stream'

  constructor: (@captionComponentClass) ->
    super

  onCreated: ->
    super

    @animatedBackgrounds = new ReactiveField true
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
    
    @_artworkAreas = []
    @activeArtworkIndex = new ReactiveField null
    @activeArtwork = new ReactiveField null, (a, b) -> a is b

  onRendered: ->
    super

    @_$window = $(window)
    @_$document = $(document)
    @_$app = $('.retronator-app')

    @_$window.on 'scroll.pixelartdatabase-components-stream', (event) => @onScroll()
    @onScroll()

    # Update active artwork on resizes and artworks updates.
    @autorun (computation) =>
      AM.Window.clientBounds()
      @displayedArtworks()

      # Reset active artwork index so that all areas get deactivated first.
      @activeArtworkIndex null

      # Wait till the new artwork areas get rendered.
      Tracker.afterFlush =>
        @measureArtworkAreas()
        @updateActiveArtwork()

    # React to active artwork changes.
    @autorun (computation) =>
      activeArtworkIndex = @activeArtworkIndex()

      # Go over all the artworks and activate the one at the new index.
      for artworkArea, index in @_artworkAreas
        # We should make active also the two neighbors.
        areaShouldBeActive = if activeArtworkIndex? then Math.abs(activeArtworkIndex - index) < 2 else false

        # Activate or deactivate areas. Note that active is undefined at the start.
        if areaShouldBeActive and artworkArea.active isnt true
          # We must activate this area.
          $artworkArea = $(artworkArea.element)

          $artworkArea.css
            visibility: 'visible'

          for video in $artworkArea.find('video')
            video.currentTime = 0
            video.play().then =>
              # HACK: Safari sometimes hides the video after it starts playing, so we trigger it to be re-rendered.
              $(video).css display: 'block'

          $backgroundVideo = $artworkArea.find('video.background')
          backgroundVideo = $backgroundVideo[0]

          if backgroundVideo
            $backgroundVideo.on 'timeupdate', =>
              return unless backgroundVideo

              newTime = backgroundVideo.currentTime
              lastTime = $backgroundVideo._lastTime

              if lastTime and newTime - lastTime > 0.55
                @playbackSkippedCount++
                @animatedBackgrounds false if @playbackSkippedCount > 2

              $backgroundVideo._lastTime = newTime

          artworkArea.active = true

        else if not areaShouldBeActive and artworkArea.active isnt false
          # We need to deactivate this area.
          $artworkArea = $(artworkArea.element)

          $(artworkArea.element).css
            visibility: 'hidden'

          for video in $artworkArea.find('video')
            video.pause()

          $backgroundVideo = $artworkArea.find('video.background')
          $backgroundVideo.off 'timeupdate'

          artworkArea.active = false

  onDestroyed: ->
    super

    @_$window.off '.pixelartdatabase-components-stream'

  renderCaption: ->
    caption = new @captionComponentClass
    caption.renderComponent @currentComponent()

  onScroll: ->
    # Measure artwork areas every 2s when scrolling.
    @_throttledMeasureArtworkAreas ?= _.throttle =>
      @measureArtworkAreas()
    ,
      2000

    @_throttledMeasureArtworkAreas()
    @updateActiveArtwork()

  measureArtworkAreas: ->
    # Get scroll top positions of all artworks.
    $artworkAreas = @$('.artwork-area')
    return unless $artworkAreas

    for artworkAreaElement, index in $artworkAreas
      @_artworkAreas[index] ?= {}
      @_artworkAreas[index].element = artworkAreaElement
      @_artworkAreas[index].top = $(artworkAreaElement).find('.artwork').offset().top

      displayedArtwork = Blaze.getData(artworkAreaElement)
      @_artworkAreas[index].artwork = displayedArtwork.artwork

  # Determines which artwork we're viewing.
  updateActiveArtwork: (options) ->
    newIndex = -1

    scrollTop = @_$window.scrollTop()

    windowHeight = @_$window.height()
    scrollBottom = scrollTop + windowHeight

    for artworkArea, index in @_artworkAreas
      if artworkArea.top < scrollBottom
        newIndex = index

      else
        break

    @activeArtworkIndex newIndex
    @activeArtwork if newIndex > -1 then @_artworkAreas[newIndex].artwork else null
