AM = Artificial.Mirage
AE = Artificial.Everywhere

# The bounds of your browser window.
class AM.Window
  @isInitialized = false

  @clientBounds = new ReactiveField null

  @isFullscreen = new ReactiveField false
  @fullscreenElement = new ReactiveField null

  @initialize: ->
    return if @isInitialized
    @isInitialized = true

    @$window = $(window)

    # Listen to resize event and set the initial dimensions.
    @$window.resize =>
      @_onResize()

    @_onResize()

    @isFullscreen false

    $(document).on 'fullscreenchange webkitfullscreenchange', =>
      @_onFullscreenChange()

    @_onFullscreenChange()

  @enterFullscreen: ->
    documentElement = document.documentElement
    documentElement.requestFullscreen?()
    documentElement.webkitRequestFullscreen?()

  @exitFullscreen: ->
    document.exitFullscreen?()
    document.webkitExitFullscreen?()

  @_onResize: ->
    @clientBounds new AE.Rectangle 0, 0, @$window.width(), @$window.height()

  @_onFullscreenChange: ->
    isFullscreen = document.fullscreen or document.webkitIsFullScreen
    fullscreenElement = document.fullscreenElement or document.webkitFullscreenElement

    @isFullscreen isFullscreen
    @fullscreenElement if isFullscreen then fullscreenElement else null
