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

  @FocusPoints:
    Sketches:
      x: 1
      y: 1
    Realistic:
      x: 0.6
      y: 0.42
    Charcoal:
      x: 0.4
      y: 0.42
    Pastels:
      x: 0.08
      y: 0.44

  @HighlightGroups:
    Sketches: ['handStudy', 'hillary', 'retropolisInternationalSpacestationMainTower', 'humanAnatomyStudies']
    PencilsPortraits: ['blackLab', 'aBrutallySoftWoman', 'alexKaylynn', 'selfPortraitWithHair', 'night21', 'skogsra', 'withersFamily', 'kaley']
    PencilsRealistc: ['blackLab', 'aBrutallySoftWoman', 'alexKaylynn', 'selfPortraitWithHair', 'skogsra', 'withersFamily']
    PencilsMechanical: ['skogsra', 'withersFamily']
    PencilsColored: ['kaley']
    PencilsEdgeShading: ['night21']
    Charcoal: ['evilIsLoveSpelledBackwards', 'inAFeeling', 'inAMoment', 'rodin']

  constructor: ->
    super

    @dialogueMode = new ReactiveField false

    @displayedArtworksFields = new ReactiveField null
    @highlightedArtworksFields = new ReactiveField []

    @_focusPoint = x: 0.5, y: 0.5
    @_scrollTop = 0

    @sceneSize =
      width: 720
      height: 360

    @artistsInfo =
      alexandraHood: name: first: 'Alexandra', last: 'Hood'
      gabrielleBrickey: name: first: 'Gabrielle', last: 'Brickey'
      matejJan: name: first: 'Matej', last: 'Jan'

    @artworksInfo =
      # Alexandra Hood
      aBrutallySoftWoman:
        artistInfo: @artistsInfo.alexandraHood
        title: 'A Brutally Soft Woman'
        caption: "Graphite on cartridge paper, 11.5 × 16.5 inches"
      alexKaylynn:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Alex + Kaylynn'
        caption: "Graphite on Bristol paper, 9 × 12 inches"
      aquaticII:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Aquatic II'
        caption: "Micron pen on brown cotton rag paper, 5 × 5 inches (deckle edge unfeatured)"
      aquaticIII:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Aquatic III'
        caption: "Micron pen on brown cotton rag paper, 5 × 5 inches (deckle edge unfeatured)"
      aquaticV:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Aquatic V'
        caption: "Micron pen on brown cotton rag paper, 5 × 5 inches (deckle edge unfeatured)"
      blackLab:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Black Lab'
        caption: "Graphite on Bristol paper, 9 × 12 inches"
      botanicalIII:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Botanical III'
        caption: "Micron pen on cotton rag paper (light green), 5 × 5 inches"
      botanicalIX:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Botanical IX'
        caption: "Micron pen on 100% Cotton Rag Paper, 5 × 5 inches"
      botanicalV:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Botanical V'
        caption: "Micron pen on cotton rag paper (light green), 5 × 5 inches"
      evilIsLoveSpelledBackwards:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Evil Is Love Spelled Backwards'
        caption: "Charcoal on paper, 16 × 20 inches"
      humanAnatomyStudies:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Human Anatomy Studies'
        caption: "Pencil in sketchbook"
      selfPortraitWithHair:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Self Portrait With Hair'
        caption: "Graphite on Bristol board, 16 × 20 inches"
      withersFamily:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Withers Family'
        caption: "Graphite on Bristol paper (mechanical pencils), 6 × 9 inches"

      # Gabrielle Brickey
      inAFeeling:
        artistInfo: @artistsInfo.gabrielleBrickey
        title: 'In a Feeling'
        caption: "Charcoal on grey paper, 9 × 12 inches"
      inAMoment:
        artistInfo: @artistsInfo.gabrielleBrickey
        title: 'In a Moment'
        caption: "Charcoal on grey paper, 9 × 12 inches"

    # Matej Jan
      cardinalCity:
        artistInfo: @artistsInfo.matejJan
        title: 'Cardinal City'
        caption: """
          Mixed media on tan paper panel
          (Paper Mate Flair felt tip pen, Prismacolor warm grey markers, red and white chalk pencils, Gelly Roll white gel pen, Molotov white acrylic pen),
          40 × 32 inches
        """
      handStudy:
        artistInfo: @artistsInfo.matejJan
        title: 'Hand Study'
        caption: "Graphite and white chalk on Toned Tan paper, 9 × 12 inches"
      hillary:
        artistInfo: @artistsInfo.matejJan
        title: 'Hillary'
        caption: "Graphite on paper, 6 × 8 inches"
      kaley:
        artistInfo: @artistsInfo.matejJan
        title: 'Kaley'
        caption: "Colored pencils on paper, 8.27 × 11.69 inches"
      night21:
        artistInfo: @artistsInfo.matejJan
        title: 'Night 21'
        caption: "Digital (Classic Pencil on Paper Grain, Linea Sketch, iPad Pro, Apple Pencil), 2048 × 2732 pixels"
      retropolisInternationalSpacestationMainTower:
        artistInfo: @artistsInfo.matejJan
        title: 'Retropolis International Spacestation: Main Tower'
        caption: "Digital (white Classic Pencil on Blueprint, Linea Sketch, iPad Pro, Apple Pencil), 2732 × 2048 pixels"
      rodin:
        artistInfo: @artistsInfo.matejJan
        title: 'Rodin'
        caption: "Charcoal on paper (pencils and sticks), 18 × 24 inches"
      skogsra:
        artistInfo: @artistsInfo.matejJan
        title: 'Skogsra'
        caption: "Graphite on Bristol vellum paper (mechanical pencils, Pentel 0.5mm 3H & 4B lead), 9 × 12 inches"

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

  setFocus: (targetFocusPoint) ->
    @_focusPoint = targetFocusPoint
    return unless @isRendered()

    @$animate.velocity('stop', 'moveFocus')
    @_updateSceneStyle()

  moveFocus: (targetFocusPoint, completeCallback) ->
    # We clamp the focus point so that it won't get clamped later.
    @_startingFocusPoint = @_clampFocusPoint @_focusPoint
    targetFocusPoint = @_clampFocusPoint targetFocusPoint

    @_moveFocusDelta =
      x: targetFocusPoint.x - @_startingFocusPoint.x
      y: targetFocusPoint.y - @_startingFocusPoint.y

    duration = 30 * Math.sqrt(Math.pow(@_moveFocusDelta.x * @sceneSize.width, 2) + Math.pow(@_moveFocusDelta.y * @sceneSize.height, 2))

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
      complete: completeCallback

    @$animate.dequeue('moveFocus')

  _clampFocusPoint: (focusPoint) ->
    viewport = LOI.adventure.interface.display.viewport()
    scale = LOI.adventure.interface.display.scale()

    halfWidth = viewport.viewportBounds.width() / scale / 2
    halfHeight = @illustrationHeight() / 2

    x: _.clamp focusPoint.x, halfWidth / @sceneSize.width, (@sceneSize.width - halfWidth) / @sceneSize.width
    y: _.clamp focusPoint.y, halfHeight / @sceneSize.height, (@sceneSize.height - halfHeight) / @sceneSize.height

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

  illustrationHeight: ->
    viewport = LOI.adventure.interface.display.viewport()
    scale = LOI.adventure.interface.display.scale()

    if @dialogueMode()
      # In dialogue mode we only fill half the screen minus one line (8rem).
      illustrationHeight = viewport.viewportBounds.height() / scale / 2 - 8

    else
      illustrationHeight = viewport.viewportBounds.height() / scale

    Math.min 360, illustrationHeight

  highlightingActiveClass: ->
    'highlighting-active' if @highlightedArtworksFields().length

  artworkClasses: (artworkField) ->
    classes = [
      _.kebabCase artworkField
      'artwork'
    ]

    classes.push 'highlighted' if artworkField in @highlightedArtworksFields()

    classes.join ' '

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

    focusFactor =
      x: _.clamp (@_focusPoint.x * @sceneSize.width * scale - viewport.viewportBounds.width() / 2) / scrollableWidth, 0, 1
      y: _.clamp (@_focusPoint.y * @sceneSize.height * scale - @illustrationHeight() * scale / 2) / scrollableHeight, 0, 1

    left = -scrollableWidth * focusFactor.x
    top = -reducedScrollableHeight * focusFactor.y

    @$scene.css transform: "translate3d(#{left}px, #{top}px, 0)"

    for parallaxItem in @_parallaxItems
      left = (parallaxItem.origin.x - focusFactor.x) * parallaxItem.depth * scrollableWidth / 10
      top = (parallaxItem.origin.y - focusFactor.y) * parallaxItem.depth * scrollableHeight / 5 - parallaxItem.depth * scrollParallaxOffset

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
      'click .artwork': @onClickArtwork

  onClickArtwork: (event) ->
    styleClasses = $(event.target).attr('class').split(' ')

    if 'aquatic-botanical' in styleClasses
      artworkFields = [
        'aquaticII'
        'aquaticIII'
        'aquaticV'
        'botanicalIII'
        'botanicalIX'
        'botanicalV'
      ]

    else
      artworkFields = (_.camelCase styleClass for styleClass in styleClasses)

    @displayArtworks artworkFields

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
