AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Components.Palette extends FM.View
  @id: -> 'LandsOfIllusions.Assets.Components.Palette'
  @register @id()

  onCreated: ->
    super arguments...

    @paletteData = new ComputedField =>
      return unless editor = @interface.getEditorForActiveFile()

      if paletteData = editor.paletteData?()
        return paletteData
      
      if paletteId = editor.paletteId?()
        LOI.Assets.Palette.forId.subscribe paletteId if paletteId
        return LOI.Assets.Palette.documents.findOne paletteId

      null
      
    @currentRampData = @interface.getComponentData(@).child 'ramp'
    @currentShadeData = @interface.getComponentData(@).child 'shade'

    @currentColor = new ComputedField =>
      @paletteData()?.ramps[@currentRampData.value()]?.shades[@currentShadeData.value()]
      
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
    @currentRampData.value ramp
    @currentShadeData.value shade

    # Deselect the material.
    materialsData = @interface.getComponentData LOI.Assets.Components.Materials
    materialsData.set 'index', null

  activeColorClass: ->
    data = @currentData()
    'active' if data.ramp is @currentRampData.value() and data.shade is @currentShadeData.value()

  events: ->
    super(arguments...).concat
      'click .color': @onClickColor

  onClickColor: ->
    data = @currentData()
    @setColor data.ramp, data.shade
