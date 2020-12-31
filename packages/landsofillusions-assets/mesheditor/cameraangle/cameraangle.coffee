AC = Artificial.Control
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

    @camera = new LOI.Assets.MeshEditor.Camera
      load: => @cameraAngle()
      save: (value) =>
        # If we hold down shift, move target and position at the same time.
        keyboardState = AC.Keyboard.getState()
        if keyboardState.isKeyDown AC.Keys.shift
          if value.position and not value.target
            sourceProperty = 'position'
            destinationProperty = 'target'

          else if value.target and not value.position
            sourceProperty = 'target'
            destinationProperty = 'position'

          if sourceProperty
            # See which coordinates changed.
            cameraAngle = @cameraAngle()

            for coordinate in ['x', 'y', 'z']
              unless cameraAngle[sourceProperty]?[coordinate] is value[sourceProperty][coordinate]
                # This coordinate is being changed, so we want to apply the same delta to the destination vector.
                delta = value[sourceProperty][coordinate] - (cameraAngle[sourceProperty]?[coordinate] or 0)

                value[destinationProperty] ?= _.clone cameraAngle[destinationProperty] or {x: 0, y: 0, z: 0}
                value[destinationProperty][coordinate] += delta

        @cameraAngle().update value

    @customMatrix = new LOI.Assets.MeshEditor.Matrix
      dimensions: 3
      rowNames: ["x'", "y'", "z'"]
      load: => @cameraAngle()?.customMatrix
      save: (value) => @cameraAngle().update customMatrix: value

    @sprite = new ComputedField =>
      @cameraAngle()?.sprite

  events: ->
    super(arguments...).concat
      'change .picture-plane-offset .coordinate-input': @onChangePicturePlaneOffsetCoordinate

  onChangePicturePlaneOffsetCoordinate: (event) ->
    $coordinates = $(event.target).closest('.coordinates')

    coordinates = {}

    for property in ['x', 'y']
      coordinates[property] = _.parseFloatOrZero $coordinates.find(".coordinate-#{property} .coordinate-input").val()

    @cameraAngle().update picturePlaneOffset: coordinates

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
      @customAttributes =
        step: 0.01

  class @PixelSize extends @CameraProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.CameraAngle.PixelSize'

    constructor: ->
      super arguments...

      @property = 'pixelSize'
      @type = AM.DataInputComponent.Types.Number
      @customAttributes =
        step: 0.001
