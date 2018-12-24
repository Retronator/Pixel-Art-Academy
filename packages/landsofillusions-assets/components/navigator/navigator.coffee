AC = Artificial.Control
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Components.Navigator extends FM.View
  @id: -> "LandsOfIllusions.Assets.Components.Navigator"
  @register @id()

  onCreated: ->
    super arguments...
    
    options = @data()

    @zoomLevels = options.value()?.zoomLevels or [12.5, 25, 50, 66.6, 100, 200, 300, 400, 600, 800, 1200, 1600, 3200]

    @zoomPercentage = new ComputedField =>
      @interface.parent.pixelCanvas().camera()?.scale() * 100

    @zoomInPressed = new ReactiveField false
    @zoomOutPressed = new ReactiveField false

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
    return unless zoomPercentage = @zoomPercentage()
    Math.round(zoomPercentage * 10, 2) / 10

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
