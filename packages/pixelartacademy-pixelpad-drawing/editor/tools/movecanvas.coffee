AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Editor.Tools.MoveCanvas extends FM.Tool
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Tools.MoveCanvas'
  @displayName: -> "Move canvas"
  
  @initialize()
  
  constructor: ->
    super arguments...

    @moving = new ReactiveField false

    @display = @interface.callAncestorWith 'display'

    # Request realtime updates when moving the canvas.
    @realtimeUpdating = @moving
    
  onActivated: ->
    pointerState = AC.Pointer.getState()
    
    if pointerState.isButtonDown AC.Buttons.auxiliary
      @startMoving()
      return
    
    # Listen for pointer down.
    $(document).on "pointerdown.pixelartacademy-pixelpad-apps-drawing-editor-tools-move", (event) =>
      $target = $(event.target)

      # Only activate when we're moving from the pixel canvas.
      return unless $target.closest('.landsofillusions-assets-spriteeditor-pixelcanvas').length
      
      @startMoving()
      
      # Wire end of dragging on pointer up.
      $(document).on "pointerup.pixelartacademy-pixelpad-apps-drawing-editor-tools-move-dragging", (event) =>
        @endMoving()

  startMoving: ->
    @moving true

    @_pointerPosition =
      x: event.clientX
      y: event.clientY

    $(document).on "pointermove.pixelartacademy-pixelpad-apps-drawing-editor-tools-move-dragging", (event) =>
      dragDelta =
        x: event.clientX - @_pointerPosition.x
        y: event.clientY - @_pointerPosition.y

      editor = @interface.getEditorForActiveFile()

      originDataField = editor.camera().originData()
      origin = originDataField.value()

      scale = editor.camera().effectiveScale()

      originDataField.value
        x: origin.x - dragDelta.x / scale
        y: origin.y - dragDelta.y / scale

      @_pointerPosition =
        x: event.clientX
        y: event.clientY
        
  endMoving: ->
    $(document).off '.pixelartacademy-pixelpad-apps-drawing-editor-tools-move-dragging'
    
    @moving false

  onDeactivated: ->
    @endMoving()
    
    $(document).off '.pixelartacademy-pixelpad-apps-drawing-editor-tools-move'
