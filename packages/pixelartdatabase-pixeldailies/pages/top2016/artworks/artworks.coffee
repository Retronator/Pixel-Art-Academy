AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.Top2016.Artworks extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.Top2016.Artworks'

  # Subscriptions
  @mostPopular: new AB.Subscription name: "#{@componentName()}.mostPopular"

  onCreated: ->
    super

    @infiniteScroll = new ReactiveField null

    @autorun (computation) =>
      return unless infiniteScroll = @infiniteScroll()

      @constructor.mostPopular.subscribe @, infiniteScroll.limit()

    @artworks = new ComputedField =>
      artworks = for artwork in PADB.Artwork.documents.find().fetch()
        # Find image URL.
        imageRepresentation = _.find artwork.representations, type: PADB.Artwork.RepresentationTypes.Image

        submission = PADB.PixelDailies.Submission.documents.findOne
          'images.imageUrl': imageRepresentation.url

        artwork.favoritesCount = submission.favoritesCount

        artwork

      artworks = _.reverse _.sortBy artworks, 'favoritesCount'

      # Add ranks.
      artwork.rank = index + 1 for artwork, index in artworks

      artworks

  onRendered: ->
    super

    stream = @childComponents(PixelArtDatabase.PixelDailies.Pages.Top2016.Components.Stream)[0]
    @infiniteScroll stream.infiniteScroll
