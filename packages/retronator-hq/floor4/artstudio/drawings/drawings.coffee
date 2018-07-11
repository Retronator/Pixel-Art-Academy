AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.Drawings extends LOI.Adventure.Context
  @id: -> 'Retronator.HQ.ArtStudio.Drawings'

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @fullName: -> "drawings"
  @description: ->
    "
      Various drawings are found in the north-west part of the studio.
    "

  @initialize()

  onCreated: ->
    super

    @sceneSize =
      width: 720
      height: 360

    @targetFocusPoint =
      x: 1
      y: 1

    @_focusPoint = @targetFocusPoint
    @_scrollTop = 0
    
    @artistsInfo =
      matejJan:
        name:
          first: 'Matej'
          last: 'Jan'
    
    @artworksInfo =
      skogsra:
        artistInfo: @artistsInfo.matejJan
        title: 'Skogsra'
        
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

      artworks

    @displayedArtworksFields = new ReactiveField null

    @displayedArtworks = new ComputedField =>
      return unless fields = @displayedArtworksFields()

      artworks = @artworks()
      artworks[field] for field in fields when artworks[field]

  onRendered: ->
    super

    @$scene = @$('.scene')

    @_parallaxItems = for element in @$('.scene *[data-depth]')
      $element = $(element)

      $element: $element
      depth: $element.data('depth')
      origin:
        x: $element.data('originX')
        y: $element.data('originY')

    # Dummy DOM element to run velocity on.
    @$animate = $('<div>')

    # Update scene style when viewport changes.
    @autorun (computation) =>
      @_updateSceneStyle()

  displayArtworks: (artworkFields) ->
    @displayedArtworksFields artworkFields

    # Create the stream component.
    stream = new @constructor.Stream @displayedArtworks

    LOI.adventure.showActivatableModalDialog
      dialog: stream

  moveFocusTo: (@targetFocusPoint, duration) ->
    @_startingFocusPoint = @_focusPoint
    @_moveFocusDelta =
      x: @targetFocusPoint.x - @_startingFocusPoint.x
      y: @targetFocusPoint.y - @_startingFocusPoint.y

    @$animate.velocity('stop', 'moveFocus').velocity
      tween: [1, 0]
    ,
      duration: duration
      easing: 'ease-in-out'
      queue: 'moveFocus'
      progress: (elements, complete, remaining, current, tweenValue) =>
        @_focusPoint =
          x: @_startingFocusPoint.x + @_moveFocusDelta.x * tweenValue
          y: @_startingFocusPoint.y + @_moveFocusDelta.y * tweenValue

        @_updateSceneStyle()

    @$animate.dequeue('moveFocus')

  illustrationHeight: ->
    viewport = LOI.adventure.interface.display.viewport()
    scale = LOI.adventure.interface.display.scale()

    Math.min 360, viewport.viewportBounds.height() / scale

  onScroll: (scrollTop) ->
    return unless @isRendered()

    @_scrollTop = scrollTop
    @_updateSceneStyle()

  _updateSceneStyle: ->
    scrollParallaxOffset = @_scrollTop / 20

    viewport = LOI.adventure.interface.display.viewport()
    scale = LOI.adventure.interface.display.scale()

    scrollableWidth = @sceneSize.width * scale - viewport.viewportBounds.width()
    scrollableHeight = @sceneSize.height * scale - @illustrationHeight() * scale

    # The scene top also needs to take into account that scrolling reduces the size of the illustration (the UI covers
    # it from the bottom). The smaller the illustration (or the bigger the scroll top), the more scrollable height
    # there is. Finally we need to account for the amount of parallax offset we can introduce from scrolling.
    reducedScrollableHeight = scrollableHeight + @_scrollTop - scrollParallaxOffset

    left = -scrollableWidth * @_focusPoint.x
    top = -reducedScrollableHeight * @_focusPoint.y

    @$scene.css transform: "translate3d(#{left}px, #{top}px, 0)"

    for parallaxItem in @_parallaxItems
      left = (parallaxItem.origin.x - @_focusPoint.x) * parallaxItem.depth * scrollableWidth / 10
      top = (parallaxItem.origin.y - @_focusPoint.y) * parallaxItem.depth * scrollableHeight / 5 - parallaxItem.depth * scrollParallaxOffset

      parallaxItem.$element.css transform: "translate3d(#{left}px, #{top}px, 0)"

  onCommand: (commandResponse) ->
    drawings = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.LookAt, drawings]
      priority: 1
      action: =>
        LOI.adventure.enterContext drawings

  events: ->
    super.concat
      'click .skogsra': @onClickSkogsra

  onClickSkogsra: (event) ->
    @displayArtworks ['skogsra']

  class @Stream extends AM.Component
    @register 'Retronator.HQ.ArtStudio.Drawings.Stream'

    constructor: (@artworks) ->
      super

      @activatable = new LOI.Components.Mixins.Activatable()

    mixins: -> [@activatable]

    artworkCaptionClass: ->
      @constructor.ArtworkCaption

    class @ArtworkCaption extends AM.Component
      @register 'Retronator.HQ.ArtStudio.Drawings.Stream.ArtworkCaption'

      authors: ->
        artwork = @data()
        authors = _.map artwork.authors, 'displayName'
        authors.join ' & '

      year: ->
        artwork = @data()
        artwork.completionDate.year or artwork.completionDate.getFullYear()
