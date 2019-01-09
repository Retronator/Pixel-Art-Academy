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

    @paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

    @currentColor = new ComputedField =>
      return unless paletteColor = @paintHelper.paletteColor()
      @paletteData()?.ramps[paletteColor.ramp]?.shades[paletteColor.shade]
      
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

  activeColorClass: ->
    color = @currentData()
    return unless currentColor = @paintHelper.paletteColor()

    'active' if color.ramp is currentColor.ramp and color.shade is currentColor.shade

  events: ->
    super(arguments...).concat
      'click .color': @onClickColor

  onClickColor: ->
    color = @currentData()
    @paintHelper.setPaletteColor color
