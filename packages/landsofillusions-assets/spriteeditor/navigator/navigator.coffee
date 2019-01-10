AC = Artificial.Control
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Navigator extends FM.View
  @id: -> "LandsOfIllusions.Assets.SpriteEditor.Navigator"
  @register @id()

  onCreated: ->
    super arguments...

    @zoomPercentage = new ComputedField =>
      @interface.getEditorForActiveFile()?.camera()?.scale() * 100

    @zoomInPressed = new ReactiveField false
    @zoomOutPressed = new ReactiveField false

  # Helpers

  zoomPercentageValue: ->
    return unless zoomPercentage = @zoomPercentage()
    Math.round(zoomPercentage * 10) / 10

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
      @interface.getEditorForActiveFile()?.camera()?.setScale zoom / 100

  onClickZoomIn: (event) ->
    @interface.getOperator(LOI.Assets.SpriteEditor.Actions.ZoomIn).execute()

  onClickZoomOut: (event) ->
    @interface.getOperator(LOI.Assets.SpriteEditor.Actions.ZoomOut).execute()
