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
      'mousedown .zoom-in-button': @onMouseDownZoomIn
      'mousedown .zoom-out-button': @onMouseDownZoomOut
      'click .zoom-in-button': @onClickZoomIn
      'click .zoom-out-button': @onClickZoomOut

  onSubmitZoomPercentage: (event) ->
    event.preventDefault()

    try
      zoom = parseInt $(event.target).val()
      @interface.getEditorForActiveFile()?.camera()?.setScale zoom / 100
      
  onMouseDownZoomIn: (event) ->
    @_triggerAudio event, true
    
  onMouseDownZoomOut: (event) ->
    @_triggerAudio event, true

  onClickZoomIn: (event) ->
    @interface.getOperator(LOI.Assets.SpriteEditor.Actions.ZoomIn).execute()
    @_triggerAudio event, false

  onClickZoomOut: (event) ->
    @interface.getOperator(LOI.Assets.SpriteEditor.Actions.ZoomOut).execute()
    @_triggerAudio event, false
    
  _triggerAudio: (event, buttonPressed) ->
    @audio.buttonPan PAA.PixelPad.Apps.Drawing.Editor.Desktop.compressPan AEc.getPanForElement event.target
    @audio.buttonPressed buttonPressed
