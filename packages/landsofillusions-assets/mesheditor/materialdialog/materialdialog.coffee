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

  textureName: ->
    return unless material = @material()
    return material.texture.spriteName if material.texture?.spriteName

    return unless spriteId = material.texture?.spriteId
    return unless sprite = LOI.Assets.Sprite.documents.findOne spriteId

    sprite.name or sprite._id

  events: ->
    super(arguments...).concat
      'click .texture-browse-button': @onClickTextureBrowseButton

  onClickTextureBrowseButton: (event) ->
    material = @material()

    @interface.displayDialog
      contentComponentId: LOI.Assets.MeshEditor.SpriteSelectDialog.id()
      contentComponentData:
        open: (selectedItem) =>
          # We need to replace instead of update material data since we want to remove texture fields (update only merges values).
          materialData = material.toPlainObject()
          materialData.texture ?= {}

          if _.endsWith selectedItem.name, '.mip'
            materialData.texture.spriteName = selectedItem.name
            delete materialData.texture.spriteId

          else
            materialData.texture.spriteId = selectedItem._id
            delete materialData.texture.spriteName

          material.replace materialData

  class @MaterialProperty extends AM.DataInputComponent
    onCreated: ->
      super arguments...

    load: ->
      material = @data()
      material[@property]

    save: (value) ->
      material = @data()

      if @type is AM.DataInputComponent.Types.Number
        value = parseFloat value
        value = null if _.isNaN value

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
      for name, value of LOI.Engine.Materials.Types
        {name, value}

    load: ->
      super(arguments...) or LOI.Engine.Materials.Types.RampMaterial

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
