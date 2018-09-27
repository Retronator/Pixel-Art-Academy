AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.MoveCamera extends LOI.Assets.Tools.Tool
  constructor: ->
    super

    @name = "Move camera"
    @shortcut = AC.Keys.c

    @moving = new ReactiveField false

    @_rotationMode = false

    @display = @options.editor().callAncestorWith 'display'

  onActivated: ->
    # Listen for mouse down.
    $(document).on "mousedown.landsofillusions-assets-mesheditor-tools-movecamera", (event) =>
      $target = $(event.target)

      # Only activate when we're moving on the canvas.
      return unless $target.closest('.landsofillusions-assets-components-pixelcanvas').length

      @moving true

      @_mousePosition =
        x: event.clientX
        y: event.clientY

      # Wire end of dragging on mouse up.
      $(document).on "mouseup.landsofillusions-assets-mesheditor-tools-movecamera-dragging", (event) =>
        $(document).off '.landsofillusions-assets-mesheditor-tools-movecamera-dragging'
        @moving false

      $(document).on "mousemove.landsofillusions-assets-mesheditor-tools-movecamera-dragging", (event) =>
        cameraManager = @options.editor().meshCanvas().cameraManager()

        x = -(event.clientX - @_mousePosition.x)
        y = event.clientY - @_mousePosition.y

        if @_rotationMode
          cameraManager.moveAroundTarget x, y
          
        else
          cameraManager.move x, y

        @_mousePosition =
          x: event.clientX
          y: event.clientY

    # Listen for keys.
    $(document).on "keydown.landsofillusions-assets-mesheditor-tools-movecamera", (event) =>
      @_rotationMode = true if event.which is AC.Keys.shift

    $(document).on "keyup.landsofillusions-assets-mesheditor-tools-movecamera", (event) =>
      @_rotationMode = false if event.which is AC.Keys.shift

  onDeactivated: ->
    $(document).off '.landsofillusions-assets-mesheditor-tools-movecamera'
