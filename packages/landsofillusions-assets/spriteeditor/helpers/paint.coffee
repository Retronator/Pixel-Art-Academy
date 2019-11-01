FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Helpers.Paint extends FM.Helper
  # paletteColor: pixel color from the palette
  #   ramp
  #   shade
  # directColor: directly specified color of the pixel
  #   r, g, b: (0.0-1.0)
  # materialIndex: the index of the named color of the pixel
  # normal: the direction of the surface that this pixel represents in right-handed 3D coordinates
  #   x, y, z
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Helpers.Paint'
  @initialize()
  
  constructor: ->
    super arguments...

    @normal = new ComputedField =>
      normal = @data.get('normal') or x: 0, y: 0, z: 1
      THREE.Vector3.fromObject normal

    @activeFileData = new ComputedField =>
      @interface.getComponentDataForActiveFile @
  
  paletteColor: -> @data.get 'paletteColor'
  directColor: -> @data.get 'directColor'
  materialIndex: -> @data.get 'materialIndex'
  layerIndex: -> @activeFileData()?.get('layerIndex') or 0

  setPaletteColor: (paletteColor) -> @_setColor _.pick paletteColor, ['ramp', 'shade']
  setDirectColor: (directColor) -> @_setColor null, _.pick directColor, ['r', 'g', 'b']
  setMaterialIndex: (index) -> @_setColor null, null, index

  _setColor: (paletteColor = null, directColor = null, materialIndex = null) ->
    @data.set 'paletteColor', paletteColor
    @data.set 'directColor', directColor
    @data.set 'materialIndex', materialIndex
    
  setNormal: (normal) ->
    @data.set 'normal', if normal then _.pick normal, ['x', 'y', 'z'] else null

  setLayerIndex: (index) ->
    @activeFileData().set 'layerIndex', index
