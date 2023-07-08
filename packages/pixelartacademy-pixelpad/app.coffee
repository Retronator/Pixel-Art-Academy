AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.App extends LOI.Adventure.Item
  @_appClassesByUrl = {}

  @getClassForUrl: (url) ->
    @_appClassesByUrl[url]

  @initialize: ->
    super arguments...

    url = @url()
    @_appClassesByUrl[url] = @ if url?

  @iconUrl: -> @versionedUrl "/pixelartacademy/pixelpad/apps/#{@url()}/icon.png"
  iconUrl: -> @constructor.iconUrl()

  constructor: (@os) ->
    super arguments...

    # Does this app lets the device resize?
    @resizable = new ReactiveField true

    # The minimum size the device should be let to resize.
    @minWidth = new ReactiveField null
    @minHeight = new ReactiveField null

    # The maximum size the device should be let to resize.
    @maxWidth = new ReactiveField null
    @maxHeight = new ReactiveField null

  allowsShortcutsTable: ->
    # Override to display shortcuts table in the app.
    false

  onRendered: ->
    super arguments...
    
    $appWrapper = $('.app-wrapper')
    $appWrapper.velocity 'transition.slideUpIn', complete: ->
      $appWrapper.css('transform', '')

  setDefaultPixelPadSize: ->
    @setMaximumPixelPadSize()

    @minWidth 310
    @minHeight 230

    @resizable true
    
  setFixedPixelPadSize: (width, height) ->
    @minWidth width
    @minHeight height

    @maxWidth width
    @maxHeight height

    @resizable false

  setMinimumPixelPadSize: ->
    @setFixedPixelPadSize 310, 230

  setMaximumPixelPadSize: (options = {}) ->
    display = LOI.adventure.interface.display

    viewport = display.viewport()
    scale = display.scale()

    maxOverlayHeight = display.safeAreaHeight() * 1.5

    width = viewport.viewportBounds.width() / scale
    height = Math.min maxOverlayHeight, viewport.viewportBounds.height() / scale

    unless options.fullscreen
      # Add gaps for the back button and top border
      width -= 100
      height -= 20

    @setFixedPixelPadSize width, height

  maximize: ->
    @os.pixelPad.size
      width: @maxWidth()
      height: @maxHeight()
