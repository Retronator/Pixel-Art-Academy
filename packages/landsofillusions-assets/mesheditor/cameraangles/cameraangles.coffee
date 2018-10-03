AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.CameraAngles extends AM.Component
  @register 'LandsOfIllusions.Assets.MeshEditor.CameraAngles'

  constructor: (@options) ->
    super arguments...

    @meshData = new ComputedField =>
      LOI.Assets.Mesh.documents.findOne @options.meshId(),
        fields:
          cameraAngles: 1

    @assetsList = new ReactiveField null

  onCreated: ->
    super arguments...

    @camera = new LOI.Assets.Components.Camera
      load: => @cameraAngleData()
      save: (value) => LOI.Assets.Mesh.updateCameraAngle @options.meshId(), @options.cameraAngleIndex(), value

    @assetsList new LOI.Assets.Components.AssetsList
      documentClass: LOI.Assets.Sprite
      getAssetId: => @cameraAngleData()?.sprite?._id
      setAssetId: (spriteId) => LOI.Assets.Mesh.updateCameraAngle @options.meshId(), @options.cameraAngleIndex(), sprite: _id: spriteId

  cameraAngles: ->
    return unless cameraAngles = @meshData()?.cameraAngles

    # Add index information.
    cameraAngle.index = index for cameraAngle, index in cameraAngles

    cameraAngles

  activeClass: ->
    cameraAngle = @currentData()
    'active' if cameraAngle.index is @options.cameraAngleIndex()

  nameOrIndex: ->
    cameraAngle = @currentData()
    cameraAngle.name or cameraAngle.index

  cameraAngleData: ->
    @meshData()?.cameraAngles?[@options.cameraAngleIndex()]

  events: ->
    super(arguments...).concat
      'click .camera-angle': @onClickCameraAngle
      'click .add-camera-angle-button': @onClickAddCameraAngleButton

  onClickCameraAngle: (event) ->
    cameraAngle = @currentData()
    @options.cameraAngleIndex cameraAngle.index

  onClickAddCameraAngleButton: (event) ->
    index = @meshData().cameraAngles?.length or 0

    LOI.Assets.Mesh.updateCameraAngle @options.meshId(), index,
      picturePlaneDistance: 32
      pixelSize: 0.01
      position: x: 0, y: 1, z: -2
      target: x: 0, y: 1, z: 0
      up: x: 0, y: 1, z: 0

    @options.cameraAngleIndex index

  class @CameraProperty extends AM.DataInputComponent
    onCreated: ->
      super arguments...

      @meshEditor = @ancestorComponentOfType LOI.Assets.MeshEditor

    load: ->
      cameraAngleData = @data()
      cameraAngleData[@property]

    save: (value) ->
      cameraAngleData = @data()
      meshId = @meshEditor.meshId()
      cameraAngleIndex = cameraAngleData.index

      if @type is AM.DataInputComponent.Types.Number
        value = parseFloat value
        value = null if _.isNaN value

      LOI.Assets.Mesh.updateCameraAngle meshId, cameraAngleIndex, "#{@property}": value

  class @Name extends @CameraProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.CameraAngles.Name'

    constructor: ->
      super arguments...

      @property = 'name'

  class @PicturePlaneDistance extends @CameraProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.CameraAngles.PicturePlaneDistance'

    constructor: ->
      super arguments...

      @property = 'picturePlaneDistance'
      @type = AM.DataInputComponent.Types.Number

  class @PixelSize extends @CameraProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.CameraAngles.PixelSize'

    constructor: ->
      super arguments...

      @property = 'pixelSize'
      @type = AM.DataInputComponent.Types.Number
      @customAttributes =
        step: 0.1
