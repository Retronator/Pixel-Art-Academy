AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Components.Palette extends FM.View
  @id: -> 'LandsOfIllusions.Assets.Components.Palette'
  @register @id()

  constructor: ->
    super arguments...

    @paletteData = new ComputedField =>
      return unless @isCreated()

      if paletteData = @interface.parent.paletteData?()
        return paletteData
      
      if paletteId = @interface.parent.paletteId?()
        LOI.Assets.Palette.forId.subscribe paletteId if paletteId
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
