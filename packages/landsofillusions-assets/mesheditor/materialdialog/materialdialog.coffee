AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MaterialDialog extends FM.View
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.MaterialDialog'
  @register @id()

  onCreated: ->
    super arguments...

    @mesh = new ComputedField =>
      @interface.getLoaderForActiveFile()?.meshData()

    @material = new ComputedField =>
      return unless dialogData = @data()
      @mesh()?.materials.get dialogData.materialIndex

    @paletteData = new ComputedField =>
      @interface.getLoaderForActiveFile()?.palette()

    @textureMappingMatrix = new LOI.Assets.MeshEditor.TextureMappingMatrix
      load: => @material()?.texture?.mappingMatrix
      save: (value) =>
        material = @material()
        texture = material.texture or {}
        texture.mappingMatrix = value

        material.update {texture}

  windowData: ->
    title: @material()?.name or 'Material'

  textureIsAssigned: ->
    return unless material = @material()
    material.texture?.spriteName or material.texture?.spriteId

  textureIsMip: ->
    return unless material = @material()
    _.endsWith material.texture?.spriteName, '.mip'

  textureName: ->
    return unless material = @material()
    return material.texture.spriteName if material.texture?.spriteName

    return unless spriteId = material.texture?.spriteId
    return unless sprite = LOI.Assets.Sprite.documents.findOne spriteId

    sprite.name or sprite._id

  events: ->
    super(arguments...).concat
      'click .texture-browse-button': @onClickTextureBrowseButton
      'change .texture-offset .coordinate-input': @onChangeTextureOffsetCoordinateInput

  onClickTextureBrowseButton: (event) ->
    material = @material()

    @interface.displayDialog
      contentComponentId: LOI.Assets.MeshEditor.SpriteSelectDialog.id()
      contentComponentData:
        selectItem: material.texture?.spriteId or material.texture?.spriteName
        open: (selectedItem) =>
          materialData = material.toPlainObject()
          texture = materialData.texture or {}

          if selectedItem
            if _.endsWith selectedItem.name, '.mip'
              texture.spriteName = selectedItem.name
              texture.spriteId = null

            else
              texture.spriteId = selectedItem._id
              texture.spriteName = null

          else
            texture.spriteId = null
            texture.spriteName = null

          material.update {texture}

  onChangeTextureOffsetCoordinateInput: (event) ->
    $coordinates = $(event.target).closest('.coordinates')

    coordinates = {}

    for property in ['x', 'y']
      coordinates[property] = _.parseFloatOrZero $coordinates.find(".coordinate-#{property} .coordinate-input").val()

    material = @material()

    texture = _.clone material.texture or {}
    texture.mappingOffset = coordinates

    material.update {texture}

  class @MaterialProperty extends AM.DataInputComponent
    onCreated: ->
      super arguments...

    load: ->
      material = @data()
      material[@property]

    save: (value) ->
      material = @data()

      if @type is AM.DataInputComponent.Types.Number
        value = _.parseFloatOrNull value

      material.update "#{@property}": value

  class @Name extends @MaterialProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.MaterialDialog.Name'

    constructor: ->
      super arguments...

      @property = 'name'

  class @Type extends @MaterialProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.MaterialDialog.Type'

    constructor: ->
      super arguments...

      @property = 'type'
      @type = AM.DataInputComponent.Types.Select

    options: ->
      for id in LOI.Engine.Materials.Material.getIds()
        name: id
        value: id

    load: ->
      super(arguments...) or LOI.Engine.Materials.RampMaterial.id()

  class @Ramp extends @MaterialProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.MaterialDialog.Ramp'

    constructor: ->
      super arguments...

      @property = 'ramp'
      @type = AM.DataInputComponent.Types.Number

      @customAttributes =
        min: 0

  class @Shade extends @MaterialProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.MaterialDialog.Shade'

    constructor: ->
      super arguments...

      @property = 'shade'
      @type = AM.DataInputComponent.Types.Number

      @customAttributes =
        min: 0

  class @Dither extends @MaterialProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.MaterialDialog.Dither'

    constructor: ->
      super arguments...

      @property = 'dither'
      @type = AM.DataInputComponent.Types.Number

      @customAttributes =
        min: 0
        max: 1
        step: 0.1

  class @TextureProperty extends AM.DataInputComponent
    onCreated: ->
      super arguments...

    load: ->
      material = @data()
      material.texture?[@property]

    save: (value) ->
      material = @data()

      if @type is AM.DataInputComponent.Types.Number
        value = _.parseFloatOrNull value

      texture = _.clone material.texture or {}
      texture[@property] = value

      material.update {texture}

  class @AnisotropicFiltering extends @TextureProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.MaterialDialog.AnisotropicFiltering'

    constructor: ->
      super arguments...

      @property = 'anisotropicFiltering'
      @type = AM.DataInputComponent.Types.Checkbox

  class @FilterProperty extends @TextureProperty
    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    options: ->
      options = []

      for name, value of LOI.Assets.Mesh.TextureFilters
        options.push {name, value}

      options

    save: (value) ->
      # Convert to null if empty string.
      super value or null

  class @MinificationFilter extends @FilterProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.MaterialDialog.MinificationFilter'

    constructor: ->
      super arguments...

      @property = 'minificationFilter'

  class @MagnificationFilter extends @FilterProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.MaterialDialog.MagnificationFilter'

    constructor: ->
      super arguments...

      @property = 'magnificationFilter'

  class @MipmapFilter extends @FilterProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.MaterialDialog.MipmapFilter'

    constructor: ->
      super arguments...

      @property = 'mipmapFilter'

  class @MipmapBias extends @TextureProperty
    @register 'LandsOfIllusions.Assets.MeshEditor.MaterialDialog.MipmapBias'

    constructor: ->
      super arguments...

      @property = 'mipmapBias'
      @type = AM.DataInputComponent.Types.Number
      @placeholder = 0
      @customAttributes =
        step: 0.1
