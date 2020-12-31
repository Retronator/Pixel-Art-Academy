AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Gallery.ArtworksGroup extends LOI.Adventure.Item
  displayInLocation: -> false

  constructor: ->
    super arguments...

    @artistsInfo =
      matejJan: name: first: 'Matej', last: 'Jan'

  onCreated: ->
    super arguments...

    # Subscribe to artists and artworks.
    for artistField, artistInfo of @artistsInfo
      if artistInfo.name
        PADB.Artist.forName.subscribe @, artistInfo.name
        PADB.Artwork.forArtistName.subscribe @, artistInfo.name

      else if artistInfo.pseudonym
        PADB.Artist.forPseudonym.subscribe @, artistInfo.pseudonym
        PADB.Artwork.forArtistPseudonym.subscribe @, artistInfo.pseudonym

    @artists = new ComputedField =>
      artists = {}

      for artistField, artistInfo of @artistsInfo
        if artistInfo.name
          artists[artistField] = PADB.Artist.forName.query(artistInfo.name).fetch()[0]

        else if artistInfo.pseudonym
          artists[artistField] = PADB.Artist.documents.findOne pseudonym: artistInfo.pseudonym

      artists

    @artworks = new ComputedField =>
      artworks = []

      for artworkField, artworkInfo of @artworksInfo
        if artworkInfo.artistInfo.name
          artist = PADB.Artist.forName.query(artworkInfo.artistInfo.name).fetch()[0]

        else if artworkInfo.artistInfo.pseudonym
          artist = PADB.Artist.documents.findOne pseudonym: artworkInfo.artistInfo.pseudonym

        continue unless artist

        if artworkInfo.url
          # Search by URL.
          artwork = PADB.Artwork.forUrl.query(artworkInfo.url).fetch()[0]

        else
          # Search by title.
          artwork = PADB.Artwork.documents.findOne
            'authors._id': artist._id
            title: artworkInfo.title

        if artwork
          # Forward the caption.
          artwork.caption = artworkInfo.caption

          # Set if it's non-pixel art (true for all physical artworks).
          artwork.nonPixelArt = artworkInfo.nonPixelArt or artwork.type is PADB.Artwork.Types.Physical

          artworks.push artwork

      artworks

  onRendered: ->
    super arguments...

    # Create the stream component.
    stream = new HQ.Gallery.ArtworksGroup.Stream @artworks

    LOI.adventure.showActivatableModalDialog
      dialog: stream
      callback: =>
        LOI.adventure.deactivateActiveItem()

  # Inform the graphics engine that this item renders a fullscreen UI, hiding the rest of the interface.
  hasFullscreenUI: -> true

  onCommand: (commandResponse) ->
    artworksGroup = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.LookAt, artworksGroup]
      priority: 1
      action: =>
        LOI.adventure.goToItem artworksGroup
        true

  class @Stream extends AM.Component
    @register 'Retronator.HQ.Gallery.ArtworksGroup.Stream'

    constructor: (@artworks) ->
      super arguments...

      @activatable = new LOI.Components.Mixins.Activatable()

    mixins: -> [@activatable]

    onRendered: ->
      super arguments...

      $(window).scrollTop 0

    onDestroyed: ->
      super arguments...

      $(window).scrollTop 0

    streamOptions: ->
      captionComponentClass: @constructor.ArtworkCaption
      scrollParentSelector: '.retronator-hq-gallery-artworksgroup-stream'
      display: LOI.adventure.interface.display

    events: ->
      super(arguments...).concat
        'click': @onClick

    onClick: (event) ->
      @activatable.deactivate()

    class @ArtworkCaption extends AM.Component
      @register 'Retronator.HQ.Gallery.ArtworksGroup.Stream.ArtworkCaption'

      authors: ->
        artwork = @data()
        authors = (artist.displayName for artist in artwork.authors)
        authors.join ' & '

      year: ->
        artwork = @data()
        artwork.completionDate.year or artwork.completionDate.getFullYear()
