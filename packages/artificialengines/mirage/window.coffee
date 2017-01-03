AM = Artificial.Mirage
AE = Artificial.Everywhere

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

    $(document).on 'fullscreenchange webkitfullscreenchange mozfullscreenchange msfullscreenchange', =>
      @_onFullscreenChange()

    @_onFullscreenChange()

  @enterFullscreen: ->
    body = $('body')[0]

    body.requestFullscreen?()
    body.webkitRequestFullscreen?()
    body.mozRequestFullScreen?()
    body.msRequestFullscreen?()

  @exitFullscreen: ->
    document.exitFullscreen?()
    document.webkitExitFullscreen?()
    document.mozCancelFullScreen?()
    document.msExitFullscreen?()

  @_onResize: ->
    @clientBounds new AE.Rectangle 0, 0, @$window.width(), @$window.height()

  @_onFullscreenChange: ->
    isFullscreen = document.fullscreen or document.webkitIsFullScreen or document.mozFullScreen
    fullscreenElement = document.fullscreenElement or document.webkitFullscreenElement or document.mozFullScreenElement or document.msFullscreenElement

    @isFullscreen isFullscreen
    @fullscreenElement if isFullscreen then fullscreenElement else null
