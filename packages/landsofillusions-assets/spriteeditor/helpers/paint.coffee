FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Helpers.Paint extends FM.Helper
  # paletteColor: indexed color from the palette
  #   ramp
  #   shade
  # paletteId: the palette from which to index or null for the restricted palette
  # directColor: directly specified color of the pixel
  #   r, g, b: (0.0-1.0)
  # opacity: opacity of the paint (0.0-1.0)
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
      
    @opacity = new ComputedField =>
      @data.get('opacity') ? 1
  
  paletteColor: -> @data.get 'paletteColor'
  paletteId: -> @data.get 'paletteId'
  directColor: -> @data.get 'directColor'
  materialIndex: -> @data.get 'materialIndex'
  layerIndex: -> @activeFileData()?.get('layerIndex') or 0

  setPaletteColor: (paletteColor) -> @_setColor _.pick paletteColor, ['ramp', 'shade']
  setDirectColor: (directColor) -> @_setColor null, _.pick directColor, ['r', 'g', 'b']
  setMaterialIndex: (index) -> @_setColor null, null, index
  setClearColor: -> @_setColor null, null, null
    
  isPaintSet: -> @paletteColor() or @directColor() or @materialIndex()?

  _setColor: (paletteColor = null, directColor = null, materialIndex = null) ->
    @data.set 'paletteColor', paletteColor
    @data.set 'directColor', directColor
    @data.set 'materialIndex', materialIndex

  setPaletteId: (paletteId) ->
    @data.set 'paletteId', paletteId
    
  setOpacity: (opacity) ->
    @data.set 'opacity', opacity

  setNormal: (normal) ->
    @data.set 'normal', if normal then _.pick normal, ['x', 'y', 'z'] else null

  setLayerIndex: (index) ->
    @activeFileData().set 'layerIndex', index

  getColor: ->
    paletteColor = @paletteColor()
    asset = @interface.getLoaderForActiveFile()?.asset()
    
    if materialIndex = @materialIndex()
      # Find the indexed color of the material.
      return unless paletteColor = asset?.materials[materialIndex]
    
    if paletteColor
      # Resolve indexed color.
      if paletteId = @paletteId()
        # We need a specific palette document.
        return unless paletteData = LOI.Assets.Palette.documents.findOne paletteId

      else
        # We need a restricted palette from the asset.
        return unless paletteData = asset?.getRestrictedPalette()
        
      colorData = paletteData.ramps[paletteColor.ramp]?.shades[paletteColor.shade]
      
    else
      # See if we have a direct color.
      colorData = @directColor()
    
    return unless colorData

    THREE.Color.fromObject colorData

  applyPaintToPixels: (pixels) ->
    paint =
      directColor: @directColor()
      paletteColor: @paletteColor()
      materialIndex: @materialIndex()
      normal: @normal()?.toObject()
      alpha: @opacity()
    
    for property, value of paint when value?
      pixel[property] = value for pixel in pixels
