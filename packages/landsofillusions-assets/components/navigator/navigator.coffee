AC = Artificial.Control
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.Navigator extends AM.Component
  @register "LandsOfIllusions.Assets.Components.Navigator"

  @zoomLevels: [12.5, 25, 50, 66.6, 100, 200, 300, 400, 600, 800, 1200, 1600, 3200]

  constructor: (@options) ->
    super

    @zoomPercentage = new ComputedField =>
      @options.camera()?.scale() * 100

  onRendered: ->
    super

    $(window).on 'keydown.landsofillusions-assets-components-navigator', (event) =>
      return unless AC.Keyboard.getState().isCommandDown()

      switch event.keyCode
        when AC.Keys.equalSign
          event.preventDefault()
          @zoomIn()

        when AC.Keys.dash
          event.preventDefault()
          @zoomOut()

  onDestroyed: ->
    $(window).off('.landsofillusions-assets-components-navigator')

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
    @options.camera()?.scale percentage / 100

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
