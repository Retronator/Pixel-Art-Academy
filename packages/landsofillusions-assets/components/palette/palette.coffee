AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.Palette extends AM.Component
  @register 'LandsOfIllusions.Assets.Components.Palette'

  constructor: (@options) ->
    super arguments...

    @paletteData = new ComputedField =>
      if paletteData = @options.paletteData?()
        return paletteData
      
      if paletteId = @options.paletteId?()
        LOI.Assets.Palette.forId.subscribeContent paletteId if paletteId
        return LOI.Assets.Palette.documents.findOne paletteId

      null
    
    @currentRamp = new ReactiveField null
    @currentShade = new ReactiveField null

    @currentColor = new ComputedField =>
      @paletteData()?.ramps[@currentRamp()]?.shades[@currentShade()]
      
  palette: ->
    return unless paletteData = @paletteData()

    # Go over all shades of all ramps.
    ramps = for ramp, rampIndex in paletteData.ramps
      shades = for shade, shadeIndex in ramp.shades
        ramp: rampIndex
        shade: shadeIndex
        color: THREE.Color.fromObject shade

      {shades}
    {ramps}

  colorStyle: ->
    color = @currentData().color

    backgroundColor: "##{color.getHexString()}"

  setColor: (ramp, shade) ->
    @currentRamp ramp
    @currentShade shade

    # Deselect the material.
    if materials = @options.materials?()
      materials.setIndex null

  activeColorClass: ->
    data = @currentData()
    'active' if data.ramp is @currentRamp() and data.shade is @currentShade()

  events: ->
    super(arguments...).concat
      'click .color': @onClickColor

  onClickColor: ->
    data = @currentData()
    @setColor data.ramp, data.shade
