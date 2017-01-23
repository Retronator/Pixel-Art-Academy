AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.Top2016.Artworks extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.Top2016.Artworks'

  # Subscriptions
  @mostPopular: new AB.Subscription name: "#{@componentName()}.mostPopular"

  onCreated: ->
    super
    
    @limit = new ReactiveField 10

    @autorun (computation) =>    
      @constructor.mostPopular.subscribe @, @limit()

    @artworks = new ComputedField =>
      artworks = for artwork in PADB.Artwork.documents.find().fetch()
        # Add extra data to artworks.
        for representation in artwork.representations
          if representation.type is PADB.Artwork.RepresentationTypes.Image
            artwork.imageUrl ?= representation.url

          if representation.type is PADB.Artwork.RepresentationTypes.Video
            artwork.videoUrl ?= representation.url

        submission = PADB.PixelDailies.Submission.documents.findOne
          'images.imageUrl': artwork.imageUrl

        artwork.favoritesCount = submission.favoritesCount

        artwork

      _.reverse _.sortBy artworks, 'favoritesCount'

  onRendered: ->
    $window = $(window)
    $document = $(document)

    $window.on 'scroll.artworks', (event) =>
      scrollTop = $window.scrollTop()

      # Increase limit when we're inside the last 2 window heights of the page.
      triggerTop = $document.height() - $window.height() * 3

      if scrollTop > triggerTop
        # Only increase the limit if we actually have that many artworks on the client.
        if @limit() is @artworks().length
          @limit @limit() + 10
