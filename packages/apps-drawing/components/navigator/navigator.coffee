AC = Artificial.Control
AM = Artificial.Mirage

class PixelArtAcademy.PixelBoy.Apps.Drawing.Components.Navigator extends AM.Component
  @register "PixelArtAcademy.PixelBoy.Apps.Drawing.Components.Navigator"

  @zoomLevels: [200, 300, 400, 500, 600, 800, 1000, 1200]

  constructor: (@options) ->
    super

    @zoomPercentage = new ComputedField =>
      @options.viewport()?.scale() * 100

  onRendered: ->
    super

    $(window).on 'keydown.navigator', (event) =>
      return unless AC.Keyboard.getState().isCommandDown()

      switch event.keyCode
        when AC.Keys.equalSign
          event.preventDefault()
          @zoomIn()

        when AC.Keys.dash
          event.preventDefault()
          @zoomOut()

  onDestroyed: ->
    $(window).off('.navigator')

  zoomIn: ->
    percentage = @zoomPercentage()

    for zoomLevel in @constructor.zoomLevels
      if zoomLevel > percentage
        percentage = zoomLevel
        break

    @setZoom percentage

  zoomOut: ->
    percentage = @zoomPercentage()

    for zoomLevel in @constructor.zoomLevels by -1
      if zoomLevel < percentage
        percentage = zoomLevel
        break

    @setZoom percentage

  setZoom: (percentage) ->
    @options.viewport()?.scale percentage / 100

  # Helpers
  zoomPercentageValue: ->
    Math.round(@zoomPercentage() * 10, 2) / 10

  # Events
  events: ->
    super.concat
      'change .zoom-percentage-input': @onSubmitZoomPercentage
      'click .zoom-in-button': @onClickZoomIn
      'click .zoom-out-button': @onClickZoomOut

  onSubmitZoomPercentage: (event) ->
    event.preventDefault()

    try
      zoom = parseInt $(event.target).val()
      @setZoom zoom

  onClickZoomIn: (event) ->
    @zoomIn()

  onClickZoomOut: (event) ->
    @zoomOut()
