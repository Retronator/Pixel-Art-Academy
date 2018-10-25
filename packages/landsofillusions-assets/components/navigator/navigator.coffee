AC = Artificial.Control
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.Navigator extends AM.Component
  @register "LandsOfIllusions.Assets.Components.Navigator"

  constructor: (@options) ->
    super arguments...

    @zoomLevels = @options.zoomLevels or [12.5, 25, 50, 66.6, 100, 200, 300, 400, 600, 800, 1200, 1600, 3200]

    @zoomPercentage = new ComputedField =>
      @options.camera()?.scale() * 100

    @zoomInPressed = new ReactiveField false
    @zoomOutPressed = new ReactiveField false

  onRendered: ->
    super arguments...

    $(document).on 'keydown.landsofillusions-assets-components-navigator', (event) =>
      switch event.keyCode
        when AC.Keys.equalSign
          @zoomIn()
          @zoomInPressed true

        when AC.Keys.dash
          @zoomOut()
          @zoomOutPressed true

        else
          return

      # Also allow for cmd/ctrl combination.
      keyboardState = AC.Keyboard.getState()
      event.preventDefault() if keyboardState.isCommandOrCtrlDown()

    $(document).on 'keyup.landsofillusions-assets-components-navigator', (event) =>
      switch event.which
        when AC.Keys.equalSign
          @zoomInPressed false

        when AC.Keys.dash
          @zoomOutPressed false

  onDestroyed: ->
    super arguments...
    
    $(document).off('.landsofillusions-assets-components-navigator')

  zoomIn: ->
    percentage = @zoomPercentage()

    for zoomLevel in @zoomLevels
      if zoomLevel > percentage
        percentage = zoomLevel
        break

    @setZoom percentage

  zoomOut: ->
    percentage = @zoomPercentage()

    for zoomLevel in @zoomLevels by -1
      if zoomLevel < percentage
        percentage = zoomLevel
        break

    @setZoom percentage

  setZoom: (percentage) ->
    @options.camera()?.setScale percentage / 100

  # Helpers

  zoomPercentageValue: ->
    Math.round(@zoomPercentage() * 10, 2) / 10

  zoomInPressedClass: ->
    'pressed' if @zoomInPressed()

  zoomOutPressedClass: ->
    'pressed' if @zoomOutPressed()

  # Events

  events: ->
    super(arguments...).concat
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
