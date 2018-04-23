AM = Artificial.Mirage
LOI = LandsOfIllusions

class PixelArtAcademy.PixelBoy.Apps.Drawing.Components.ColorMap extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Components.ColorMap'

  constructor: (@options) ->
    super

    @assetData = new ComputedField =>
      assetId = @options.assetId()
      LOI.Assets[@options.assetClassName].documents.findOne assetId,
        fields:
          colorMap: 1
          palette: 1

    @currentIndex = new ReactiveField null

  onCreated: ->
    super

    # Subscribe to the palette of this sprite.
    @autorun =>
      sprite = @assetData()
      return unless sprite

      @paletteSubscriptionHandle = Meteor.subscribe 'palette', sprite.palette._id

    # Select first index when image is first loaded.
    @autorun (computation) =>
      data = @assetData()
      return unless data
      return if @_completedForId is data._id

      @_completedForId = data._id

      colorIndices = Object.keys data.colorMap
      @selectIndex colorIndices[0] ? null

  selectIndex: (index) ->
    # Make sure index is a number and not a string. But it could be null to for deselecting.
    index = parseInt index if index?

    # Set current brush index.
    @currentIndex index

    return unless index?

    # Display the same ramp in the palette.
    palette = @options.palette()
    return unless palette

    color = @assetData().colorMap[index]
    palette.currentRamp color.ramp
    palette.currentShade color.shade

  selectIndexWithRamp: (ramp) ->
    @currentIndex @getIndexWithRamp ramp

  getIndexWithRamp: (ramp) ->
    data = @assetData()
    return unless data

    currentIndex = @currentIndex()

    # Skip if current index is already with desired ramp
    return currentIndex if data.colorMap[currentIndex]?.ramp is ramp

    # Find first index with this ramp.
    for index of data.colorMap
      if data.colorMap[index].ramp is ramp
        return parseInt index

    # No indexed color matches this ramp.
    null

  addNewIndex: (name, ramp, shade) ->
    # Find a free index.
    asset = @assetData()

    newIndex = 0
    while asset.colorMap[newIndex]
      newIndex++

    Meteor.call 'colorMapSetColor', asset._id, @options.assetClassName, newIndex, name, ramp, shade

    newIndex

  # Helpers

  colors: ->
    data = @assetData()
    return null unless data

    colors = []

    for index of data.colorMap
      colors.push $.extend {}, data.colorMap[index],
        index: parseInt index

    colors

  colorPreviewStyle: ->
    return unless @paletteSubscriptionHandle.ready()
    
    data = @currentData()
    palette = LOI.Assets.Palette.documents.findOne @assetData().palette._id

    ramp = data.ramp or 0
    maxShade = palette.ramps[ramp].shades.length - 1
    shade = THREE.Math.clamp data.shade or 0, 0, maxShade

    color = THREE.Color.fromObject palette.ramps[ramp].shades[shade]

    backgroundColor: "##{color.getHexString()}"

  activeColorClass: ->
    data = @currentData()
    'active' if data.index is @currentIndex()

  events: ->
    super.concat
      'click .preview-color': @onClickPreviewColor
      'change .color-name-input, change .ramp-input, change .shade-input': @onChangeColor
      'click .add-color': @onClickAddColor

  onClickPreviewColor: (event) ->
    data = @currentData()
    @selectIndex data.index

  onChangeColor: (event) ->
    $color = $(event.target).closest('.color')

    index = @_parseIntOrNull @currentData().index
    return unless index?

    name = $color.find('.color-name-input').val()
    ramp = @_parseIntOrNull $color.find('.ramp-input').val()
    shade = @_parseIntOrNull $color.find('.shade-input').val()

    Meteor.call 'colorMapSetColor', @assetData()._id, @options.assetClassName, index, name, ramp, shade

  onClickAddColor: (event) ->
    @addNewIndex()

  _parseIntOrNull: (string) ->
    try
      int = parseInt string

    if int / 1 is int then int else null
