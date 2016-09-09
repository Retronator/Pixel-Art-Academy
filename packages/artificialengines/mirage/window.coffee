AM = Artificial.Mirage
AE = Artificial.Everywhere

class AM.Window
  @clientBounds = new ReactiveField null
  @isInitialized = false

  @initialize: ->
    return if @isInitialized
    @isInitialized = true

    @$window = $(window)

    # Listen to resize event and set the initial dimensions.
    @$window.resize =>
      @_onResize()

    @_onResize()

  @_onResize: ->
    @clientBounds new AE.Rectangle 0, 0, @$window.width(), @$window.height()
