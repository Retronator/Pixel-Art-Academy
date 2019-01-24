AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.CameraAngle extends FM.View
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.CameraAngle'
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

    @camera = new LOI.Assets.Components.Camera
      load: => @cameraAngle()
      save: (value) =>
        LOI.Assets.Mesh.updateCameraAngle @mesh()._id, @cameraAngleIndex(), value

    @sprite = new ComputedField => 
      @cameraAngle()?.sprite

  setSprite: (spriteId) ->
    LOI.Assets.Mesh.updateCameraAngle @mesh()._id, @cameraAngleIndex(), sprite: _id: spriteId

  filename: ->
    cameraAngle = @currentData()
    cameraAngle.sprite?.name or cameraAngle.sprite?._id

  events: ->
    super(arguments...).concat
      'click .sprite .value': @onClickSprite
      
  onClickSprite: (event) ->
    @interface.displayDialog
      contentComponentId: LOI.Assets.MeshEditor.CameraAngle.SelectSpriteDialog.id()

  class @CameraProperty extends AM.DataInputComponent
    onCreated: ->
      super arguments...

      @cameraAngleComponent = @ancestorComponentOfType LOI.Assets.MeshEditor.CameraAngle

    load: ->
      cameraAngle = @data()
      cameraAngle[@property]

    save: (value) ->
      cameraAngle = @data()
      meshId = @cameraAngleComponent.mesh()._id
      cameraAngleIndex = cameraAngle.index

      if @type is AM.DataInputComponent.Types.Number
        value = parseFloat value
        value = null if _.isNaN value

      LOI.Assets.Mesh.updateCameraAngle meshId, cameraAngleIndex, "#{@property}": value

  class @Name extends @CameraProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.CameraAngle.Name'

    constructor: ->
      super arguments...

      @property = 'name'

    placeholder: ->
      cameraAngle = @data()
      "Camera angle #{cameraAngle.index}"

  class @PicturePlaneDistance extends @CameraProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.CameraAngle.PicturePlaneDistance'

    constructor: ->
      super arguments...

      @property = 'picturePlaneDistance'
      @type = AM.DataInputComponent.Types.Number

  class @PixelSize extends @CameraProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.CameraAngle.PixelSize'

    constructor: ->
      super arguments...

      @property = 'pixelSize'
      @type = AM.DataInputComponent.Types.Number
      @customAttributes =
        step: 0.1
