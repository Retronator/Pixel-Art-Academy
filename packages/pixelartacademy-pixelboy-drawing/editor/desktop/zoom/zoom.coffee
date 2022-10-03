AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelBoy.Apps.Drawing.Editor.Desktop.Zoom extends FM.View
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Desktop.Zoom'
  @register @id()
  
  template: -> @constructor.id()

  onCreated: ->
    super arguments...

    @editor = new ComputedField =>
      @interface.getEditorForActiveFile()
    ,
      (a, b) => a is b

    @zoomPercentage = new ComputedField =>
      @interface.getEditorForActiveFile()?.camera()?.scale() * 100

    @zoomInPressed = new ReactiveField false
    @zoomOutPressed = new ReactiveField false

  # Helpers

  zoomPercentageValue: ->
    return unless zoomPercentage = @zoomPercentage()
    Math.round zoomPercentage

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
