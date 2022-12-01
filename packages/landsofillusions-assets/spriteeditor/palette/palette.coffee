AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Palette extends FM.View
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Palette'
  @register @id()

  onCreated: ->
    super arguments...

    # Minimize reactivity of augmenting palette colors (derived classes rely on this).
    @paletteData = new ComputedField =>
      @interface.getLoaderForActiveFile()?.asset()?.getRestrictedPalette()
    ,
      EJSON.equals

    @palette = new ComputedField =>
      return unless paletteData = @paletteData()

      # Go over all shades of all ramps.
      ramps = for ramp, rampIndex in paletteData.ramps
        shades = for shade, shadeIndex in ramp.shades
          ramp: rampIndex
          shade: shadeIndex
          color: THREE.Color.fromObject shade

        {shades}
      {ramps}

    @paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

    @currentColor = new ComputedField =>
      return unless paletteColor = @paintHelper.paletteColor()
      @paletteData()?.ramps[paletteColor.ramp]?.shades[paletteColor.shade]

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
