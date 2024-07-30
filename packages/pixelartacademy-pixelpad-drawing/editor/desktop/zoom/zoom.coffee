AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Zoom extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Zoom'
  @register @id()
  
  template: -> @constructor.id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    # Loaded from the PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop namespace.
    subNamespace: true
    variables:
      buttonPressed: AEc.ValueTypes.Boolean
      buttonPan: AEc.ValueTypes.Number
      
  onCreated: ->
    super arguments...

    @editor = new ComputedField =>
      @interface.getEditorForActiveFile()
    ,
      (a, b) => a is b

    @zoomPercentage = new ComputedField =>
      @interface.getEditorForActiveFile()?.camera()?.targetScale() * 100

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
      'pointerdown .zoom-in-button': @onPointerDownZoomIn
      'pointerdown .zoom-out-button': @onPointerDownZoomOut
      'click .zoom-in-button': @onClickZoomIn
      'click .zoom-out-button': @onClickZoomOut

  onSubmitZoomPercentage: (event) ->
    event.preventDefault()

    try
      zoom = parseInt $(event.target).val()
      @interface.getEditorForActiveFile()?.camera()?.scaleTo zoom / 100, 0.2
      
  onPointerDownZoomIn: (event) ->
    @_triggerAudio event, true
    
  onPointerDownZoomOut: (event) ->
    @_triggerAudio event, true

  onClickZoomIn: (event) ->
    @interface.getOperator(PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.ZoomIn).execute()
    @_triggerAudio event, false

  onClickZoomOut: (event) ->
    @interface.getOperator(PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.ZoomOut).execute()
    @_triggerAudio event, false
    
  _triggerAudio: (event, buttonPressed) ->
    @audio.buttonPan PAA.PixelPad.Apps.Drawing.Editor.Desktop.compressPan AEc.getPanForElement event.target
    @audio.buttonPressed buttonPressed
