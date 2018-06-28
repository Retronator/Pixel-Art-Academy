AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.Materials extends AM.Component
  @register 'LandsOfIllusions.Assets.Components.Materials'

  constructor: (@options) ->
    super

    @assetData = new ComputedField =>
      assetId = @options.assetId()
      @options.documentClass.documents.findOne assetId,
        fields:
          materials: 1
          palette: 1

    @currentIndex = new ReactiveField null

  onCreated: ->
    super

    # Subscribe to the palette of this asset.
    @autorun =>
      assetData = @assetData()
      return unless assetData?.palette?._id

      @paletteSubscriptionHandle = LOI.Assets.Palette.forId.subscribe assetData.palette._id

    # Deselect index if it's outside asset's materials.
    @autorun (computation) =>
      return if @assetData()?.materials?[@currentIndex()]
      
      Tracker.nonreactive => @currentIndex null

  setIndex: (index) ->
    # Make sure index is a number and not a string. But it could be null too for deselecting.
    index = parseInt index if index?

    # Set current material index.
    @currentIndex index

    # Deselect the color in the palette if we've set one of our own.
    if index? and palette = @options.palette()
      palette.currentRamp null

  selectIndexWithRamp: (ramp) ->
    @currentIndex @getIndexWithRamp ramp

  getIndexWithRamp: (ramp) ->
    data = @assetData()
    return unless data

    currentIndex = @currentIndex()

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
    if palette = @options.palette()
      material =
        ramp: palette.currentRamp()
        shade: palette.currentShade()

    LOI.Assets.VisualAsset.updateMaterial @options.documentClass.className, asset._id, newIndex, material

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
    maxShade = palette.ramps[ramp].shades.length - 1
    shade = THREE.Math.clamp colorData.shade or 0, 0, maxShade

    color = THREE.Color.fromObject palette.ramps[ramp].shades[shade]

    backgroundColor: "##{color.getHexString()}"

  activeColorClass: ->
    data = @currentData()
    'active' if data.index is @currentIndex()

  events: ->
    super.concat
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

    LOI.Assets.VisualAsset.updateMaterial @options.documentClass.className, @assetData()._id, index, material

  onClickAddMaterialButton: (event) ->
    @addNewIndex()

  _parseIntOrNull: (string) ->
    int = parseInt string

    if _.isNaN int then null else int

  _parseFloatOrNull: (string) ->
    float = parseFloat string

    if _.isNaN float then null else float
