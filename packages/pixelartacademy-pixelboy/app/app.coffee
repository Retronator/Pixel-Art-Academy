AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.App extends LOI.Adventure.Item
  @_appClassesByUrl = {}

  @getClassForUrl: (url) ->
    @_appClassesByUrl[url]

  @initialize: ->
    super

    url = @url()
    @_appClassesByUrl[url] = @ if url?
        
  iconUrl: ->
    @versionedUrl "/pixelartacademy/pixelboy/apps/#{@url()}/icon.png"

  constructor: (@os) ->
    super

    # Does this app lets the device resize?
    @resizable = new ReactiveField true

    # Should the home screen button be shown?
    @showHomeScreenButton = new ReactiveField true

    # The minimum size the device should be let to resize.
    @minWidth = new ReactiveField null
    @minHeight = new ReactiveField null

    # The maximum size the device should be let to resize.
    @maxWidth = new ReactiveField null
    @maxHeight = new ReactiveField null

  onRendered: ->
    super
    
    $appWrapper = $('.app-wrapper')
    $appWrapper.velocity 'transition.slideUpIn', complete: ->
      $appWrapper.css('transform', '')

    # Wait for OS to determine its root.
    Tracker.afterFlush =>
      @os.$root.addClass('pixel-art-academy-style-console-app') if @useConsoleTheme
    
  onDestroyed: ->
    super

    @os.$root.removeClass('pixel-art-academy-style-console-app') if @useConsoleTheme

  setDefaultPixelBoySize: ->
    @minWidth 310
    @minHeight 230

    @maxWidth null
    @maxHeight null

    @resizable true
