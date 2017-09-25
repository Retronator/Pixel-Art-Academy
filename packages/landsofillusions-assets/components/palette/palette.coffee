AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.Palette extends AM.Component
  @register 'LandsOfIllusions.Assets.Components.Palette'

  constructor: (@options) ->
    super

    @paletteData = new ComputedField =>
      paletteId = @options.paletteId()

      LOI.Assets.Palette.forId.subscribe @, paletteId if paletteId

      LOI.Assets.Palette.documents.findOne paletteId
    
    @currentRamp = new ReactiveField null
    @currentShade = new ReactiveField null

    @currentColor = new ComputedField =>
      @paletteData()?.ramps[@currentRamp()]?.shades[@currentShade()]
      
  palette: ->
    # Prepare ramps and shades with extra information. First deep copy the data.
    data = @paletteData()
    return unless data

    palette = $.extend true, {}, data

    # Go over all shades of all ramps.
    rampIndex = 0
    for ramp in palette.ramps
      shadeIndex = 0
      for shade in ramp.shades
        # Replace the data in this place with extra information.
        palette.ramps[rampIndex].shades[shadeIndex] =
          ramp: rampIndex
          shade: shadeIndex
          color: THREE.Color.fromObject shade

        shadeIndex++
      rampIndex++

    palette

  colorStyle: ->
    color = @currentData().color

    backgroundColor: "##{color.getHexString()}"

  setColor: (ramp, shade) ->
    @currentRamp ramp
    @currentShade shade

    # Deselect the material.
    if materials = @options.materials()
      materials.setIndex null

  activeColorClass: ->
    data = @currentData()
    'active' if data.ramp is @currentRamp() and data.shade is @currentShade()

  events: ->
    super.concat
      'click .color': @onClickColor

  onClickColor: ->
    data = @currentData()
    @setColor data.ramp, data.shade
