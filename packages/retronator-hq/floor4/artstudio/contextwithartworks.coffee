AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.ContextWithArtworks extends LOI.Adventure.Context
  constructor: ->
    super

    @displayedArtworksFields = new ReactiveField null
    @highlightedArtworksFields = new ReactiveField []

  onCreated: ->
    super

    # Subscribe to artists and artworks.
    for artistField, artistInfo of @artistsInfo
      PADB.Artist.forName.subscribe @, artistInfo.name
      PADB.Artwork.forArtistName.subscribe @, artistInfo.name

    @artists = new ComputedField =>
      artists = {}

      for artistField, artistInfo of @artistsInfo
        artists[artistField] = PADB.Artist.forName.query(artistInfo.name).fetch()[0]

      artists

    @artworks = new ComputedField =>
      artworks = {}

      for artworkField, artworkInfo of @artworksInfo
        artist = PADB.Artist.forName.query(artworkInfo.artistInfo.name).fetch()[0]
        continue unless artist

        artworks[artworkField] = PADB.Artwork.documents.findOne
          'authors._id': artist._id
          title: artworkInfo.title

        # Also forward the caption.
        artworks[artworkField].caption = artworkInfo.caption

      artworks

    @displayedArtworks = new ComputedField =>
      return unless fields = @displayedArtworksFields()

      artworks = @artworks()
      artworks[field] for field in fields when artworks[field]

  displayArtworks: (artworkFields) ->
    @displayedArtworksFields artworkFields

    # Create the stream component.
    stream = new @constructor.Stream @displayedArtworks

    LOI.adventure.showActivatableModalDialog
      dialog: stream

  highlight: (artworkFields) ->
    if @highlightedArtworksFields().length
      # We need to first cancel highlighting for a frame.
      Meteor.clearTimeout @_highlightEndTimeout
      @highlightedArtworksFields []

      Tracker.afterFlush => @highlight artworkFields

    else
      @highlightedArtworksFields artworkFields or []

      @_highlightEndTimeout = Meteor.setTimeout =>
        @highlightedArtworksFields []
      ,
        5000

  highlightingActiveClass: ->
    'highlighting-active' if @highlightedArtworksFields().length

  artworkClasses: (artworkField) ->
    classes = [
      _.kebabCase artworkField
      'artwork'
    ]

    classes.push 'highlighted' if artworkField in @highlightedArtworksFields()

    classes.join ' '

  events: ->
    super.concat
      'click .artwork': @onClickArtwork

  onClickArtwork: (event) ->
    styleClasses = $(event.target).attr('class').split(' ')

    artworkFields = (_.camelCase styleClass for styleClass in styleClasses)

    @displayArtworks artworkFields

  class @Stream extends AM.Component
    @register 'Retronator.HQ.ArtStudio.ContextWithArtworks.Stream'

    constructor: (@artworks) ->
      super

      @activatable = new LOI.Components.Mixins.Activatable()

    mixins: -> [@activatable]

    artworkCaptionClass: ->
      @constructor.ArtworkCaption

    class @ArtworkCaption extends AM.Component
      @register 'Retronator.HQ.ArtStudio.ContextWithArtworks.Stream.ArtworkCaption'

      authors: ->
        artwork = @data()
        authors = _.map artwork.authors, 'displayName'
        authors.join ' & '

      year: ->
        artwork = @data()
        artwork.completionDate.year or artwork.completionDate.getFullYear()
