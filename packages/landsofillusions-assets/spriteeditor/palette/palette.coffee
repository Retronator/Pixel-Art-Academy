AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
FM = FataMorgana
LOI = LandsOfIllusions

_lch = {}

class LOI.Assets.SpriteEditor.Palette extends LOI.View
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
          color = THREE.Color.fromObject shade
          color.getLCh _lch
          _lch.c += 10 if _lch.c
          _lch.h -= AR.Degrees 10

          if _lch.l < 50
            _lch.l += 20
            
          else
            _lch.l -= 20
  
          accentColor = new THREE.Color().setLCh _lch.l, _lch.c, _lch.h
          
          # TODO: Remove when upgrading three.js and getHex includes clamping.
          accentColor.r = THREE.MathUtils.clamp accentColor.r, 0, 1
          accentColor.g = THREE.MathUtils.clamp accentColor.g, 0, 1
          accentColor.b = THREE.MathUtils.clamp accentColor.b, 0, 1

          ramp: rampIndex
          shade: shadeIndex
          color: color
          accentColor: accentColor

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

  onClickColor: (event) ->
    color = @currentData()
    @paintHelper.setPaletteColor color
