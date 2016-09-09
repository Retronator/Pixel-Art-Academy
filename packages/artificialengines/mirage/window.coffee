AM = Artificial.Mirage
AE = Artificial.Everywhere

class AM.Window
  constructor: (@app) ->
    @app.services.addService @constructor, @

    @clientBounds = new ReactiveField null

    # Listen to resize event and set the initial dimensions.
    $(window).resize =>
      @_onResize()

    @_onResize()

  _onResize: ->
    $window = $(window)
    @clientBounds new AE.Rectangle 0, 0, $window.width(), $window.height()
