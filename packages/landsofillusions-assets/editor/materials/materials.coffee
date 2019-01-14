AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Materials extends FM.View
  @id: -> 'LandsOfIllusions.Assets.Editor.Materials'
  @register @id()

  onCreated: ->
    super arguments...

    @assetData = new ComputedField =>
      @interface.getLoaderForActiveFile()?.asset()

    @paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

    # Subscribe to the palette of this asset.
    @autorun =>
      assetData = @assetData()
      return unless assetData?.palette?._id

      @paletteSubscriptionHandle = LOI.Assets.Palette.forId.subscribe assetData.palette._id

    # Deselect index if it's outside asset's materials.
    @autorun (computation) =>
      return unless index = @paintHelper.materialIndex()
      return if @assetData()?.materials?[index]
      
      Tracker.nonreactive => @paintHelper.setMaterialIndex null

  setIndex: (index) ->
    # Make sure index is a number and not a string. But it could be null too for deselecting.
    index = parseInt index if index?

    # Set current material index.
    @paintHelper.setMaterialIndex index

  selectIndexWithRamp: (ramp) ->
    @paintHelper.setMaterialIndex @getIndexWithRamp ramp

  getIndexWithRamp: (ramp) ->
    data = @assetData()
    return unless data

    currentIndex = @paintHelper.materialIndex()

    # Skip if current index is already with desired ramp
    return currentIndex if data.materials[currentIndex]?.ramp is ramp

    # Find first index with this ramp.
    for index of data.materials
      if data.materials[index].ramp is ramp
        return parseInt index

    # No indexed color matches this ramp.
    null

  addNewIndex: ->
    # Find a free index.
    asset = @assetData()

    newIndex = 0
    while asset.materials?[newIndex]
      newIndex++

    # Set the initial ramp and shade from the palette.
    material = @paintHelper.paletteColor()
    LOI.Assets.VisualAsset.updateMaterial asset.constructor.className, asset._id, newIndex, material

    newIndex

  # Helpers

  colors: ->
    data = @assetData()
    return unless data?.materials

    for index, material of data.materials
      # Add index to named color data.
      _.extend {}, material, index: parseInt index

  colorPreviewStyle: ->
    colorData = @currentData()
    return unless palette = LOI.Assets.Palette.documents.findOne @assetData()?.palette?._id

    ramp = colorData.ramp or 0
    return unless shades = palette.ramps[ramp]?.shades

    maxShade = shades.length - 1
    shade = THREE.Math.clamp colorData.shade or 0, 0, maxShade
    color = THREE.Color.fromObject shades[shade]

    backgroundColor: "##{color.getHexString()}"

  activeColorClass: ->
    data = @currentData()
    'active' if data.index is @paintHelper.materialIndex()

  events: ->
    super(arguments...).concat
      'click .preview-color': @onClickPreviewColor
      'change .name-input, change .ramp-input, change .shade-input, change .dither-input': @onChangeMaterial
      'click .add-material-button': @onClickAddMaterialButton

  onClickPreviewColor: (event) ->
    data = @currentData()
    @setIndex data.index

  onChangeMaterial: (event) ->
    $material = $(event.target).closest('.material')

    index = @_parseIntOrNull @currentData().index
    return unless index?

    material =
      # We null the name if it's an empty string
      name: $material.find('.name-input').val() or null
      ramp: @_parseIntOrNull $material.find('.ramp-input').val()
      shade: @_parseIntOrNull $material.find('.shade-input').val()
      dither: @_parseFloatOrNull $material.find('.dither-input').val()

    asset = @assetData()
    LOI.Assets.VisualAsset.updateMaterial asset.constructor.className, asset._id, index, material

  onClickAddMaterialButton: (event) ->
    @addNewIndex()

  _parseIntOrNull: (string) ->
    int = parseInt string

    if _.isNaN int then null else int

  _parseFloatOrNull: (string) ->
    float = parseFloat string

    if _.isNaN float then null else float
