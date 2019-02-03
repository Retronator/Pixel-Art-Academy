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

  events: ->
    super(arguments...).concat
      'change .picture-plane-offset .coordinate-input': @onChangePicturePlaneOffsetCoordinate

  onChangePicturePlaneOffsetCoordinate: (event) ->
    $coordinates = $(event.target).closest('.coordinates')

    coordinates = {}

    for property in ['x', 'y']
      coordinates[property] = @_parseFloatOrZero $coordinates.find(".coordinate-#{property} .coordinate-input").val()

    @cameraAngle().update picturePlaneOffset: coordinates

  _parseFloatOrZero: (string) ->
    float = parseFloat string

    if _.isNaN float then 0 else float

  class @CameraProperty extends AM.DataInputComponent
    onCreated: ->
      super arguments...

      @cameraAngleComponent = @ancestorComponentOfType LOI.Assets.MeshEditor.CameraAngle

    load: ->
      cameraAngle = @data()
      cameraAngle[@property]

    save: (value) ->
      cameraAngle = @data()

      if @type is AM.DataInputComponent.Types.Number
        value = parseFloat value
        value = null if _.isNaN value

      cameraAngle.update "#{@property}": value

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
