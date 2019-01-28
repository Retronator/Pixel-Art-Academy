AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.CameraAngles extends FM.View
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.CameraAngles'
  @register @id()

  onCreated: ->
    super arguments...

    @mesh = new ComputedField =>
      @interface.getLoaderForActiveFile()?.meshData()

    @editor = new ComputedField =>
      @interface.getEditorForActiveFile()

    @cameraAngleIndex = new ComputedField =>
      @editor()?.cameraAngleIndex()

    @cameraAngle = new ComputedField =>
      @editor()?.cameraAngle()

  setCameraAngleIndex: (index) ->
    editorView = @interface.getEditorViewForActiveFile()
    fileData = editorView.activeFileData()
    fileData.set 'cameraAngleIndex', index
    
    # Also reset the camera offset if it was applied.
    editor = editorView.getActiveEditor()
    editor.renderer.cameraManager.reset()

  cameraAngles: ->
    @mesh()?.cameraAngles.getAll()

  activeClass: ->
    cameraAngle = @currentData()
    'active' if cameraAngle.index is @cameraAngleIndex()

  placeholderName: ->
    cameraAngle = @currentData()
    "Camera angle #{cameraAngle.index}"
    
  showRemoveButton: ->
    # We can remove a camera angle if it exists.
    @cameraAngle()

  events: ->
    super(arguments...).concat
      'click .camera-angle': @onClickCameraAngle
      'click .add-button': @onClickAddButton
      'change .name-input': @onChangeCameraAngle

  onClickCameraAngle: (event) ->
    cameraAngle = @currentData()
    @setCameraAngleIndex cameraAngle.index

  onClickAddButton: (event) ->
    mesh = @mesh()
    index = mesh.cameraAngles.insert
      picturePlaneDistance: 32
      pixelSize: 0.01
      position: x: 0, y: 1, z: 2
      target: x: 0, y: 1, z: 0
      up: x: 0, y: 1, z: 0

    # Switch to new camera angle.
    @setCameraAngleIndex index

  onChangeCameraAngle: (event) ->
    cameraAngle = @currentData()
    $layer = $(event.target).closest('.camera-angle')

    newData =
      name: $layer.find('.name-input').val()

    cameraAngle.update newData
