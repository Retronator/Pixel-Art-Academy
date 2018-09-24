AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.CameraAngles extends AM.Component
  @register 'LandsOfIllusions.Assets.MeshEditor.CameraAngles'

  constructor: (@options) ->
    super

    @meshData = new ComputedField =>
      LOI.Assets.Mesh.documents.findOne @options.meshId(),
        fields:
          cameraAngles: 1

    @currentIndex = new ReactiveField null

    @assetsList = new ReactiveField null

  onCreated: ->
    super

    @camera = new LOI.Assets.Components.Camera
      load: => @cameraAngleData()
      save: (value) => LOI.Assets.Mesh.updateCameraAngle @options.meshId(), @currentIndex(), value

    @assetsList new LOI.Assets.Components.AssetsList
      documentClass: LOI.Assets.Sprite
      getAssetId: => @cameraAngleData()?.sprite?._id
      setAssetId: (spriteId) => LOI.Assets.Mesh.updateCameraAngle @options.meshId(), @currentIndex(), sprite: _id: spriteId

  cameraAngles: ->
    return unless cameraAngles = @meshData()?.cameraAngles

    # Add index information.
    cameraAngle.index = index for cameraAngle, index in cameraAngles

    cameraAngles

  activeClass: ->
    cameraAngle = @currentData()
    'active' if cameraAngle.index is @currentIndex()

  nameOrIndex: ->
    cameraAngle = @currentData()
    cameraAngle.name or cameraAngle.index

  cameraAngleData: ->
    @meshData()?.cameraAngles[@currentIndex()]

  events: ->
    super.concat
      'click .camera-angle': @onClickCameraAngle
      'click .add-camera-angle-button': @onClickAddCameraAngleButton

  onClickCameraAngle: (event) ->
    cameraAngle = @currentData()
    @currentIndex cameraAngle.index

  onClickAddCameraAngleButton: (event) ->
    index = @meshData().cameraAngles?.length or 0
    LOI.Assets.Mesh.updateCameraAngle @options.meshId(), index
    @currentIndex index

  class @CameraProperty extends AM.DataInputComponent
    onCreated: ->
      super

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
      super

      @property = 'name'

  class @PicturePlaneDistance extends @CameraProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.CameraAngles.PicturePlaneDistance'

    constructor: ->
      super

      @property = 'picturePlaneDistance'
      @type = AM.DataInputComponent.Types.Number

  class @PixelSize extends @CameraProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.CameraAngles.PixelSize'

    constructor: ->
      super

      @property = 'pixelSize'
      @type = AM.DataInputComponent.Types.Number
